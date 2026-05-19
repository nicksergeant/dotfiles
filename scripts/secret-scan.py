#!/usr/bin/env python3
"""
secret-scan — sweep disk for credentials a supply-chain worm could harvest.

Threat model: malware like the Shai-Hulud npm worms reads flat files on
disk (~/.aws/credentials, ~/.npmrc, ~/.ssh/id_*, .env, etc.), greps for
known token shapes, and exfiltrates anything it can find. This script
checks the same locations from a defensive angle: each known target is
reported as clean or alerting, and the script never prints secret values
even when alerting.

A file that exists but only contains 1Password (`op://`) placeholders is
treated as safe — those resolve only under `op run`. SSH directories with
no on-disk private keys and a config pointing at the 1Password agent are
likewise reported clean.

Exit status:
    0   no real-looking secrets found
    1   one or more alerts
    2   error (bad arguments, etc.)

Stdlib only. No pip installs.
"""

from __future__ import annotations

import argparse
import json
import os
import plistlib
import re
import sqlite3
import stat
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable, Iterator, Optional

HOME = Path.home()


# ── output helpers ──────────────────────────────────────────────────────────


class Style:
    enabled = True

    @classmethod
    def wrap(cls, code: str, text: str) -> str:
        if not cls.enabled:
            return text
        return f"\033[{code}m{text}\033[0m"


def green(s: str) -> str:  return Style.wrap("32", s)
def red(s: str) -> str:    return Style.wrap("31", s)
def yellow(s: str) -> str: return Style.wrap("33", s)
def dim(s: str) -> str:    return Style.wrap("2", s)
def bold(s: str) -> str:   return Style.wrap("1", s)


# ── findings ────────────────────────────────────────────────────────────────


OK = "ok"
ALERT = "alert"
WARN = "warn"
INFO = "info"


@dataclass
class Finding:
    level: str
    category: str
    label: str
    detail: str = ""

    def glyph(self) -> str:
        return {
            OK: green("✓"),
            ALERT: red("✗"),
            WARN: yellow("!"),
            INFO: dim("·"),
        }[self.level]


@dataclass
class Report:
    items: list[Finding] = field(default_factory=list)

    def add(self, level: str, category: str, label: str, detail: str = "") -> None:
        self.items.append(Finding(level, category, label, detail))

    def alerts(self) -> list[Finding]:
        return [f for f in self.items if f.level == ALERT]

    def warns(self) -> list[Finding]:
        return [f for f in self.items if f.level == WARN]


# ── pattern library ─────────────────────────────────────────────────────────

# Strong, low-false-positive indicators of a real secret value. Order
# matters only for the (token-type) labels emitted in alerts.
SECRET_PATTERNS: list[tuple[re.Pattern[str], str]] = [
    (re.compile(r"AKIA[0-9A-Z]{16}"),                                  "AWS access key"),
    (re.compile(r"ASIA[0-9A-Z]{16}"),                                  "AWS temp credential"),
    (re.compile(r"gh[opusr]_[A-Za-z0-9]{36,}"),                        "GitHub token"),
    (re.compile(r"github_pat_[A-Za-z0-9_]{82}"),                       "GitHub fine-grained PAT"),
    (re.compile(r"npm_[A-Za-z0-9]{36,}"),                              "npm token"),
    (re.compile(r"sk-ant-(?:api|admin)\d{2}-[A-Za-z0-9_-]{80,}"),      "Anthropic API key"),
    (re.compile(r"sk-proj-[A-Za-z0-9_-]{40,}"),                        "OpenAI project key"),
    (re.compile(r"sk-(?:svcacct|admin)-[A-Za-z0-9_-]{40,}"),           "OpenAI service key"),
    (re.compile(r"sk-[A-Za-z0-9]{20,}T3BlbkFJ[A-Za-z0-9]{20,}"),       "OpenAI legacy key"),
    (re.compile(r"sk_live_[A-Za-z0-9]{24,}"),                          "Stripe live key"),
    (re.compile(r"sk_test_[A-Za-z0-9]{24,}"),                          "Stripe test key"),
    (re.compile(r"rk_live_[A-Za-z0-9]{24,}"),                          "Stripe restricted key"),
    (re.compile(r"whsec_[A-Za-z0-9]{32,}"),                            "Stripe webhook secret"),
    (re.compile(r"xox[baprs]-[A-Za-z0-9-]{10,}"),                      "Slack token"),
    (re.compile(r"AIza[0-9A-Za-z_-]{35}"),                             "Google API key"),
    (re.compile(r"hf_[A-Za-z0-9]{34,}"),                               "HuggingFace token"),
    (re.compile(r"lin_api_[A-Za-z0-9]{40,}"),                          "Linear API key"),
    (re.compile(r"dop_v1_[A-Fa-f0-9]{64}"),                            "DigitalOcean token"),
    (re.compile(r"glpat-[A-Za-z0-9_-]{20,}"),                          "GitLab PAT"),
    (re.compile(r"SG\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{40,}"),        "SendGrid API key"),
    (re.compile(r"NRAK-[A-Z0-9]{27}"),                                  "New Relic license key"),
    (re.compile(r"(?<![A-Za-z0-9])key-[0-9a-f]{32}(?![A-Za-z0-9])"),    "Mailgun API key"),
    (re.compile(r"shp(?:at|ss|ca|pa|sc)_[A-Za-z0-9]{32,}"),            "Shopify token"),
    (re.compile(r"pul-[0-9a-f]{40}"),                                   "Pulumi access token"),
    (re.compile(r"r0_[A-Za-z0-9_-]{32,}"),                              "Render API key"),
    (re.compile(r"pscale_tkn_[A-Za-z0-9]{32,}"),                        "PlanetScale token"),
    (re.compile(r"hvs\.[A-Za-z0-9_-]{24,}"),                            "Vault service token"),
    (re.compile(r"-----BEGIN (?:OPENSSH |RSA |EC |DSA |ENCRYPTED )?PRIVATE KEY-----"), "private key block"),
    # JWT — only meaningful in env-style contexts; lots of false positives
    # in code/log files, so callers gate this to env scanning.
]

JWT_PATTERN = re.compile(
    r"eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}"
)

# Env-var names that strongly imply the value should be sensitive.
SECRET_NAME_HINT = re.compile(
    r"(password|passwd|secret|token|api[_-]?key|apikey|"
    r"private[_-]?key|access[_-]?key|client[_-]?secret|"
    r"auth[_-]?token|credential|creds|webhook|salt|dsn|"
    r"connection[_-]?string|encryption[_-]?key)",
    re.IGNORECASE,
)

# Values that should not count as secrets even if the variable name hints
# at sensitivity. (PORT=3000, NODE_ENV=production, PASSWORD=changeme).
ENV_NONSECRET_VALUE = re.compile(
    r"^(?:"
    r"true|false|yes|no|on|off|null|none|undefined|nil|"
    r"\d+(?:\.\d+)?|"
    r"localhost(?::\d+)?|127\.0\.0\.1(?::\d+)?|0\.0\.0\.0(?::\d+)?|"
    r"development|production|staging|test|debug|info|warn|error|verbose|"
    r"changeme|change[_-]?this|replace[_-]?me|x{3,}|placeholder|example|sample|"
    r"your[_-]?\w+[_-]?here"
    r")$",
    re.IGNORECASE,
)

# 1Password CLI references that resolve only under `op run`.
OP_REF = re.compile(r"^\s*op://[^\s\"']+\s*$")

# Common placeholder words used in example URLs and stub creds. If both
# user and password parts of a URL are obvious placeholders, the URL is
# not flagged as carrying embedded credentials.
PLACEHOLDER_TOKEN = re.compile(
    r"^(?:"
    r"user|username|usr|root|admin|administrator|"
    r"pass|passwd|password|secret|"
    r"postgres|postgresql|mysql|mariadb|mongo|mongodb|redis|sqlite|"
    r"foo|bar|baz|test|tester|sample|example|placeholder|me|"
    r"change[_-]?me|change[_-]?this|replace[_-]?me|"
    r"your[_-]?\w+|some[_-]?\w+|my[_-]?\w+|"
    r"\d+|"
    r"<[^>]*>|\{[^}]*\}|\[[^\]]*\]"
    r")$",
    re.IGNORECASE,
)

# direnv-style export prefix used by .envrc files.
ENV_LINE = re.compile(
    r"^\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*$"
)


# ── filesystem helpers ──────────────────────────────────────────────────────


def home_rel(p: Path) -> str:
    try:
        return "~/" + str(p.relative_to(HOME))
    except ValueError:
        return str(p)


def read_text(path: Path, limit: int = 2_000_000, *,
              tail: bool = False) -> Optional[str]:
    """Read a text file, returning None on error. Caps at `limit` bytes.

    With tail=True, reads the *last* `limit` bytes instead of the first —
    useful for history files where recent entries are at the end.
    """
    try:
        with open(path, "rb") as fh:
            if tail:
                size = path.stat().st_size
                if size > limit:
                    fh.seek(size - limit)
            data = fh.read(limit + 1)
    except (PermissionError, FileNotFoundError, IsADirectoryError, OSError):
        return None
    if len(data) > limit:
        data = data[:limit]
    try:
        return data.decode("utf-8", errors="replace")
    except Exception:  # noqa: BLE001
        return None


def starts_with_private_key_header(path: Path) -> bool:
    try:
        with open(path, "rb") as fh:
            head = fh.read(256)
    except OSError:
        return False
    return b"PRIVATE KEY-----" in head


# ── value classification ────────────────────────────────────────────────────


def find_known_patterns(content: str, include_jwt: bool = False) -> list[str]:
    """Return a deduped list of secret-type labels matched in content."""
    matched: list[str] = []
    seen: set[str] = set()
    for pattern, label in SECRET_PATTERNS:
        if pattern.search(content) and label not in seen:
            matched.append(label)
            seen.add(label)
    if include_jwt and JWT_PATTERN.search(content) and "JWT" not in seen:
        matched.append("JWT")
        seen.add("JWT")
    return matched


def strip_quotes(value: str) -> str:
    v = value.strip()
    if len(v) >= 2 and v[0] in ("'", '"') and v[-1] == v[0]:
        v = v[1:-1]
    return v


URL_WITH_CREDS = re.compile(
    r"^[a-zA-Z][a-zA-Z0-9+\-.]*://(?P<user>[^/:\s@]+):(?P<pw>[^@/\s]+)@"
)


def _is_placeholder_url_cred(value: str) -> bool:
    """True if a URL has embedded user:pass but both sides look like stubs."""
    m = URL_WITH_CREDS.match(value)
    if not m:
        return False
    return bool(PLACEHOLDER_TOKEN.match(m.group("user")) and
                PLACEHOLDER_TOKEN.match(m.group("pw")))


def env_value_is_secret(name: str, raw_value: str,
                        *, strict: bool = False) -> Optional[str]:
    """Decide whether an env assignment looks like a real secret.

    Returns a short label (e.g. "AWS access key") if the value should
    trigger an alert, otherwise None.

    `strict=True` restricts detection to the strong SECRET_PATTERNS
    library — use it for `.env.example` / `.env.template` files where
    loose heuristics (URL with creds, secret-named field) would just
    flag placeholder structure.
    """
    v = strip_quotes(raw_value)
    if not v:
        return None
    # 1Password CLI placeholders — resolved only under `op run`.
    if OP_REF.match(v):
        return None
    # Pure shell variable substitution — value comes from elsewhere.
    if re.match(r"^\$\{?[A-Za-z_][A-Za-z0-9_]*\}?$", v):
        return None
    # Filesystem paths — not secrets in themselves.
    if v.startswith(("/", "~/", "./", "../")):
        return None
    # Strong pattern wins regardless of name or template status.
    for pattern, label in SECRET_PATTERNS:
        if pattern.search(v):
            return label
    if JWT_PATTERN.search(v):
        return "JWT"
    if strict:
        return None
    # Booleans, numbers, well-known sentinels.
    if ENV_NONSECRET_VALUE.match(v):
        return None
    # Exact-match placeholders (PASSWORD=password, SECRET=changeme, etc.)
    if PLACEHOLDER_TOKEN.match(v):
        return None
    # URL with embedded credentials — suppress if both sides are stubs.
    if URL_WITH_CREDS.match(v):
        if _is_placeholder_url_cred(v):
            return None
        return "URL with embedded credentials"
    # Plain URL with no auth → not a secret.
    if re.match(r"^https?://", v):
        return None
    # Variable name strongly suggests a secret and the value is something
    # non-trivial that didn't match any sentinel above. Be conservative —
    # require a reasonable length so we don't alert on stub values.
    if SECRET_NAME_HINT.search(name) and len(v) >= 12 and " " not in v:
        return "secret-named field with non-template value"
    return None


def parse_env_text(content: str) -> Iterator[tuple[int, str, str]]:
    """Yield (lineno, name, raw_value) tuples from .env-style text."""
    for lineno, line in enumerate(content.splitlines(), start=1):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        m = ENV_LINE.match(line)
        if not m:
            continue
        name, raw = m.group(1), m.group(2)
        # Strip trailing comments only when value is unquoted.
        if not (raw.startswith(("'", '"'))):
            raw = re.sub(r"\s+#.*$", "", raw)
        yield lineno, name, raw


# ── individual checks ───────────────────────────────────────────────────────


def check_ssh(report: Report) -> None:
    category = "SSH"
    ssh_dir = HOME / ".ssh"
    if not ssh_dir.is_dir():
        report.add(OK, category, "~/.ssh absent")
        return

    private_keys: list[str] = []
    ignored = {"authorized_keys", "known_hosts", "known_hosts.old",
               "config", "environment", "rc", "id_rsa.pub", "id_ed25519.pub",
               "id_ecdsa.pub", "id_dsa.pub"}
    for entry in ssh_dir.iterdir():
        if not entry.is_file():
            continue
        if entry.name in ignored or entry.name.endswith(".pub"):
            continue
        if starts_with_private_key_header(entry):
            private_keys.append(entry.name)

    if private_keys:
        report.add(ALERT, category,
                   f"{len(private_keys)} private key file(s) on disk",
                   home_rel(ssh_dir))
    else:
        report.add(OK, category, "no private keys on disk", home_rel(ssh_dir))

    config = ssh_dir / "config"
    if config.is_file():
        content = read_text(config) or ""
        if re.search(r"^\s*IdentityAgent\s+.*1password", content,
                     re.IGNORECASE | re.MULTILINE):
            report.add(INFO, category, "SSH config uses 1Password agent")


def _scan_file(category: str, path: Path, report: Report,
               *, op_template_ok: bool = True,
               include_jwt: bool = False) -> None:
    """Generic check: file exists → alert if it carries known secret shapes."""
    label = home_rel(path)
    if not path.exists():
        report.add(OK, category, "absent", label)
        return
    if path.is_symlink():
        try:
            target = path.resolve()
            label = f"{label} → {home_rel(target)}"
        except OSError:
            pass
    content = read_text(path)
    if content is None:
        report.add(WARN, category, "unreadable", label)
        return
    if not content.strip():
        report.add(OK, category, "empty", label)
        return
    matches = find_known_patterns(content, include_jwt=include_jwt)
    if matches:
        report.add(ALERT, category, ", ".join(matches), label)
        return
    if op_template_ok and "op://" in content and not has_non_op_assignments(content):
        report.add(OK, category, "1Password template only", label)
        return
    report.add(OK, category, "no known token patterns", label)


# Match credential-named fields in INI / TOML / YAML / JSON. Used by
# `_scan_credential_file` for cred-store files whose token shapes are
# opaque (no known prefix) but whose surrounding syntax is recognisable.
# The negative lookbehind prevents matching inside identifiers like
# `my_token` or `customtoken`.
CRED_KEY_RE = re.compile(
    r"""
    (?<![A-Za-z_])
    (?P<key>token|access[_-]?token|api[_-]?key|password|passwd|
            secret|client[_-]?secret|auth[_-]?token|private[_-]?key)
    \s*[:=]\s*
    ["']?(?P<value>[^\s"',}\]]+)
    """,
    re.IGNORECASE | re.VERBOSE,
)


def _scan_credential_file(category: str, path: Path, report: Report) -> None:
    """Scan a file known to hold credentials.

    Looks for strong patterns (including JWT), then for credential-named
    fields (token, password, api_key, etc.) with non-template values. Used
    for cred-store files whose token formats aren't in SECRET_PATTERNS
    (Fly.io JWT, Databricks `dapi…`, Vercel opaque, etc.) but whose
    surrounding syntax is recognisable as INI / YAML / TOML / JSON.
    """
    label = home_rel(path)
    if path.is_symlink():
        try:
            target = path.resolve()
            label = f"{label} → {home_rel(target)}"
        except OSError:
            pass
    content = read_text(path)
    if content is None:
        report.add(WARN, category, "unreadable", label)
        return
    if not content.strip():
        report.add(OK, category, "empty", label)
        return
    matches = find_known_patterns(content, include_jwt=True)
    if matches:
        report.add(ALERT, category, ", ".join(matches), label)
        return
    for m in CRED_KEY_RE.finditer(content):
        value = m.group("value")
        if len(value) < 8:
            continue
        if value.startswith("op://") or value.startswith("${"):
            continue
        if PLACEHOLDER_TOKEN.match(value) or ENV_NONSECRET_VALUE.match(value):
            continue
        report.add(ALERT, category,
                   f"{m.group('key').lower()} field with non-template value",
                   label)
        return
    report.add(OK, category, "no credential patterns", label)


def has_non_op_assignments(content: str) -> bool:
    """True if any meaningful line has content that isn't purely an op:// reference.

    Handles both KEY=value env files and non-env syntax. Critical for files
    like .npmrc whose `//registry.npmjs.org/:_authToken=value` lines don't
    start with an identifier character and so don't parse via parse_env_text.
    A scanner that only inspected env-shaped lines would mark such a file
    as "1Password template only" even when it holds a real registry token.
    """
    for line in content.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith(("#", ";")):
            continue
        m = ENV_LINE.match(line)
        if m:
            v = strip_quotes(m.group(2))
            if v and not OP_REF.match(v):
                return True
        else:
            # Non-env-shaped line — treat as "real" unless the entire stripped
            # line is just an op:// reference.
            if not OP_REF.match(stripped):
                return True
    return False


def check_aws(report: Report) -> None:
    category = "AWS"
    candidates: list[Path] = [HOME / ".aws" / "credentials",
                              HOME / ".aws" / "config"]
    for var in ("AWS_SHARED_CREDENTIALS_FILE", "AWS_CONFIG_FILE"):
        if os.environ.get(var):
            candidates.append(Path(os.environ[var]).expanduser())
    for path in dedupe(candidates):
        _scan_file(category, path, report)

    # SSO access tokens (~8h valid) and assumed-role temp creds are stored as
    # plain JSON in these cache dirs — fresh, usable creds a worm can ship whole.
    for cache_dir in (HOME / ".aws" / "sso" / "cache",
                      HOME / ".aws" / "cli" / "cache"):
        sub = f"{cache_dir.parent.name}/{cache_dir.name}"
        if not cache_dir.is_dir():
            report.add(OK, category, f"{sub} absent", home_rel(cache_dir))
            continue
        hits: list[str] = []
        for p in cache_dir.glob("*.json"):
            if not p.is_file():
                continue
            head = read_text(p, limit=4_000) or ""
            if any(k in head for k in ('"accessToken"', '"AccessKeyId"',
                                       '"SecretAccessKey"', '"SessionToken"')):
                hits.append(p.name)
        if hits:
            report.add(ALERT, category,
                       f"{len(hits)} cached credential file(s) in {sub}",
                       home_rel(cache_dir))
        else:
            report.add(OK, category, f"{sub} has no credential files",
                       home_rel(cache_dir))


def check_gcloud(report: Report) -> None:
    category = "GCP"
    base = HOME / ".config" / "gcloud"
    if not base.exists():
        report.add(OK, category, "~/.config/gcloud absent")
        return

    # ADC from `gcloud auth application-default login` contains client_secret +
    # refresh_token — no token shape the pattern library recognises, but the
    # file itself is a usable credential a worm would ship whole.
    adc = base / "application_default_credentials.json"
    if adc.is_file():
        if adc.stat().st_size > 0:
            report.add(ALERT, category, "ADC credential cached on disk", home_rel(adc))
        else:
            report.add(OK, category, "ADC file empty", home_rel(adc))
    else:
        report.add(OK, category, "ADC file absent", home_rel(adc))

    # Scan for long-lived credential JSONs (service-account keys AND
    # user-account refresh tokens under legacy_credentials/<email>/adc.json),
    # skipping ADC which is already handled above.
    cred_hits: list[str] = []
    for path in base.rglob("*.json"):
        if not path.is_file() or path == adc:
            continue
        head = read_text(path, limit=4_000) or ""
        if ('"type": "service_account"' in head
                or '"type": "authorized_user"' in head
                or '"private_key":' in head):
            cred_hits.append(home_rel(path))
    if cred_hits:
        report.add(ALERT, category,
                   f"{len(cred_hits)} long-lived credential file(s)",
                   cred_hits[0] if len(cred_hits) == 1 else f"{cred_hits[0]} (+{len(cred_hits)-1} more)")
    else:
        report.add(OK, category, "no service-account or refresh-token JSONs")

    # gcloud auth login stashes user-account refresh tokens in a SQLite DB —
    # long-lived creds that mint fresh access tokens indefinitely.
    creds_db = base / "credentials.db"
    if creds_db.is_file() and creds_db.stat().st_size > 0:
        report.add(ALERT, category,
                   "gcloud auth login refresh tokens cached",
                   home_rel(creds_db))

    # gcloud stores short-lived access tokens in a SQLite database.
    tokens_db = base / "access_tokens.db"
    if tokens_db.is_file():
        try:
            conn = sqlite3.connect(f"file:{tokens_db}?mode=ro", uri=True)
            tables = {r[0] for r in conn.execute(
                "SELECT name FROM sqlite_master WHERE type='table'"
            ).fetchall()}
            has_rows = False
            for table in tables:
                try:
                    if conn.execute(f"SELECT 1 FROM [{table}] LIMIT 1").fetchone():  # noqa: S608
                        has_rows = True
                        break
                except sqlite3.Error:
                    pass
            conn.close()
            if has_rows:
                report.add(ALERT, category,
                           "gcloud access token cache non-empty",
                           home_rel(tokens_db))
            else:
                report.add(OK, category, "gcloud token cache empty", home_rel(tokens_db))
        except sqlite3.Error:
            report.add(WARN, category, "gcloud token DB unreadable", home_rel(tokens_db))


def check_npm(report: Report) -> None:
    category = "npm"
    _scan_file(category, HOME / ".npmrc", report)
    _scan_file(category, HOME / ".yarnrc", report)
    _scan_file(category, HOME / ".yarnrc.yml", report)
    _scan_file(category, HOME / ".pnpmrc", report)


def check_github(report: Report) -> None:
    category = "GitHub"
    _scan_file(category, HOME / ".config" / "gh" / "hosts.yml", report,
               op_template_ok=False)
    # ~/.gitconfig sometimes carries embedded tokens via URL rewrites.
    _scan_file(category, HOME / ".gitconfig", report)


def check_docker(report: Report) -> None:
    category = "Docker"
    cfg = HOME / ".docker" / "config.json"
    if not cfg.exists():
        report.add(OK, category, "~/.docker/config.json absent")
        return
    content = read_text(cfg) or ""
    label = home_rel(cfg)
    try:
        data = json.loads(content or "{}")
    except json.JSONDecodeError:
        # Fall back to pattern matching.
        matches = find_known_patterns(content)
        if matches:
            report.add(ALERT, category, ", ".join(matches), label)
        else:
            report.add(WARN, category, "config not valid JSON", label)
        return
    auths = data.get("auths", {}) or {}
    inline_auths = [host for host, v in auths.items()
                    if isinstance(v, dict) and v.get("auth")]
    helpers_only = bool(data.get("credsStore") or data.get("credHelpers")) and not inline_auths
    if inline_auths:
        report.add(ALERT, category,
                   f"{len(inline_auths)} inline auth entr{'y' if len(inline_auths)==1 else 'ies'}",
                   label)
    elif helpers_only:
        report.add(OK, category, "uses OS credential helper", label)
    else:
        report.add(OK, category, "no inline auths", label)


def check_kube(report: Report) -> None:
    category = "Kubernetes"
    cfg = HOME / ".kube" / "config"
    if not cfg.exists():
        report.add(OK, category, "~/.kube/config absent")
        return
    content = read_text(cfg) or ""
    label = home_rel(cfg)
    # Look for inline tokens / client-key-data; flag exec/auth-provider as
    # fine because those defer to an external command at use time.
    # client-certificate-data is the *public* client cert and not itself secret.
    suspicious = re.search(
        r"^\s*(token|password|client-key-data)\s*:\s*\S+",
        content, re.MULTILINE,
    )
    if suspicious:
        report.add(ALERT, category, "inline credential material", label)
    else:
        report.add(OK, category, "uses external auth (exec/oidc/helper)", label)


def check_vault(report: Report) -> None:
    category = "Vault"
    token = HOME / ".vault-token"
    if not token.exists():
        report.add(OK, category, "~/.vault-token absent")
        return
    size = 0
    try:
        size = token.stat().st_size
    except OSError:
        pass
    if size > 0:
        report.add(ALERT, category, "Vault token cached on disk", home_rel(token))
    else:
        report.add(OK, category, "Vault token file empty", home_rel(token))


def check_pypi(report: Report) -> None:
    _scan_file("PyPI", HOME / ".pypirc", report)


def check_cargo(report: Report) -> None:
    _scan_file("Cargo", HOME / ".cargo" / "credentials", report,
               op_template_ok=False)
    _scan_file("Cargo", HOME / ".cargo" / "credentials.toml", report,
               op_template_ok=False)


def check_ruby(report: Report) -> None:
    _scan_file("RubyGems", HOME / ".gem" / "credentials", report,
               op_template_ok=False)
    _scan_file("Bundler", HOME / ".bundle" / "config", report)


def check_terraform(report: Report) -> None:
    _scan_file("Terraform", HOME / ".terraform.d" / "credentials.tfrc.json",
               report, op_template_ok=False)
    _scan_file("Terraform", HOME / ".terraformrc", report)


def check_netrc(report: Report) -> None:
    category = "netrc"
    for name in (".netrc", "_netrc"):
        path = HOME / name
        if not path.exists():
            continue
        content = read_text(path) or ""
        label = home_rel(path)
        if re.search(r"^\s*password\s+\S+", content, re.MULTILINE):
            report.add(ALERT, category, "password entries", label)
        elif content.strip():
            report.add(WARN, category, "non-empty", label)
        else:
            report.add(OK, category, "empty", label)
    if not (HOME / ".netrc").exists() and not (HOME / "_netrc").exists():
        report.add(OK, category, "~/.netrc absent")


def check_misc_clis(report: Report) -> None:
    targets: list[tuple[str, Path]] = [
        ("Heroku",       HOME / ".netrc"),  # heroku stashes here; handled by check_netrc
        ("Fly.io",       HOME / ".fly" / "config.yml"),
        ("Wrangler",     HOME / ".wrangler" / "config" / "default.toml"),
        ("Wrangler",     HOME / ".config" / ".wrangler" / "config" / "default.toml"),
        ("Vercel",       HOME / ".local" / "share" / "com.vercel.cli" / "auth.json"),
        ("Vercel",       HOME / "Library" / "Application Support" / "com.vercel.cli" / "auth.json"),
        ("Supabase",     HOME / ".supabase" / "access-token"),
        ("Databricks",   HOME / ".databrickscfg"),
        ("Snowflake",    HOME / ".snowflake" / "config"),
        ("Snowflake",    HOME / ".snowsql" / "config"),
        ("DigitalOcean", HOME / ".config" / "doctl" / "config.yaml"),
        ("Linode",       HOME / ".config" / "linode-cli"),
        ("Hetzner",      HOME / ".config" / "hcloud" / "cli.toml"),
        ("Anthropic",    HOME / ".config" / "anthropic" / "auth.json"),
        ("OpenAI",       HOME / ".config" / "openai" / "auth.json"),
        ("HuggingFace",  HOME / ".cache" / "huggingface" / "token"),
        ("GnuPG",        HOME / ".gnupg" / "private-keys-v1.d"),
    ]
    # Categories whose files are opaque token blobs (no key=value structure) —
    # existence + non-empty is the credential signal.
    EXISTENCE_CATEGORIES = {"HuggingFace", "Supabase"}
    # Categories whose token shape isn't in SECRET_PATTERNS but whose config
    # syntax exposes credential-named fields (Fly.io JWT, Databricks `dapi…`,
    # Vercel opaque, Snowflake `password = …`, etc.).
    CRED_SHAPE_CATEGORIES = {"Fly.io", "Vercel", "Databricks", "Snowflake",
                             "Linode", "Hetzner", "Wrangler"}

    seen: set[Path] = set()
    for category, path in targets:
        if path in seen:
            continue
        seen.add(path)
        if category == "Heroku":
            # Handled inside check_netrc — skip.
            continue
        if category == "GnuPG":
            if path.is_dir() and any(path.iterdir()):
                report.add(ALERT, category, "private key material in ~/.gnupg",
                           home_rel(path))
            else:
                report.add(OK, category, "no private keys", home_rel(path))
            continue
        if category in EXISTENCE_CATEGORIES:
            if not path.is_file():
                continue
            if path.stat().st_size > 0:
                report.add(ALERT, category, "token cached on disk", home_rel(path))
            else:
                report.add(OK, category, "empty", home_rel(path))
            continue
        if not path.exists():
            continue
        if category in CRED_SHAPE_CATEGORIES:
            _scan_credential_file(category, path, report)
        else:
            _scan_file(category, path, report)


def check_shell_history(report: Report) -> None:
    category = "history"
    files = [".zsh_history", ".bash_history", ".python_history",
             ".node_repl_history", ".psql_history", ".mysql_history",
             ".sqlite_history", ".irb_history", ".lesshst"]
    any_alerts = False
    for name in files:
        path = HOME / name
        if not path.exists():
            continue
        content = read_text(path, limit=8_000_000, tail=True)
        if content is None:
            continue
        matches = find_known_patterns(content)
        if matches:
            report.add(ALERT, category,
                       f"{name}: {', '.join(matches)}",
                       home_rel(path))
            any_alerts = True
    if not any_alerts:
        report.add(OK, category, "no token patterns in shell history")


def check_shell_configs(report: Report) -> None:
    category = "shell config"
    paths: list[Path] = [
        HOME / ".zshrc", HOME / ".zshenv", HOME / ".zprofile", HOME / ".zlogin",
        HOME / ".bashrc", HOME / ".bash_profile", HOME / ".bash_login", HOME / ".profile",
        HOME / ".config" / "fish" / "config.fish",
    ]
    fish_conf_d = HOME / ".config" / "fish" / "conf.d"
    if fish_conf_d.is_dir():
        paths.extend(fish_conf_d.glob("*.fish"))

    any_alerts = False
    for path in paths:
        if not path.is_file():
            continue
        content = read_text(path, limit=4_000_000) or ""
        # Strong patterns anywhere in the file win immediately.
        matches = find_known_patterns(content)
        if matches:
            report.add(ALERT, category, ", ".join(matches), home_rel(path))
            any_alerts = True
            continue
        # Parse export-style assignments for secret-named vars with real values.
        flagged_names: list[str] = []
        for _lineno, name, raw in parse_env_text(content):
            label = env_value_is_secret(name, raw)
            if label:
                flagged_names.append(name)
        if flagged_names:
            report.add(ALERT, category,
                       f"exported secret: {', '.join(flagged_names[:3])}",
                       home_rel(path))
            any_alerts = True
    if not any_alerts:
        report.add(OK, category, "no secret values in shell configs")


def check_databases(report: Report) -> None:
    category = "databases"
    # pgpass: each non-comment line is hostname:port:database:username:password
    pgpass = HOME / ".pgpass"
    if pgpass.is_file():
        content = read_text(pgpass) or ""
        real_pw = any(
            not line.strip().startswith("#")
            and len(parts := line.strip().split(":")) >= 5
            and parts[-1] not in ("", "*")
            for line in content.splitlines()
            if line.strip()
        )
        if real_pw:
            report.add(ALERT, category, "plaintext password(s) in pgpass", home_rel(pgpass))
        else:
            report.add(OK, category, "pgpass uses wildcard or empty passwords", home_rel(pgpass))
    else:
        report.add(OK, category, "~/.pgpass absent")

    # my.cnf: look for password= under any section
    for name in (".my.cnf", "my.cnf"):
        mycnf = HOME / name
        if not mycnf.is_file():
            continue
        content = read_text(mycnf) or ""
        if re.search(r"^\s*password\s*=\s*\S", content, re.MULTILINE):
            report.add(ALERT, category, "plaintext password in my.cnf", home_rel(mycnf))
        else:
            report.add(OK, category, "my.cnf has no plain password", home_rel(mycnf))
        break
    else:
        report.add(OK, category, "~/.my.cnf absent")

    # Redis CLI auth URL in REDISCLI_AUTH or redis.conf
    redis_conf = HOME / ".config" / "redis" / "redis.conf"
    if redis_conf.is_file():
        _scan_file(category, redis_conf, report)


def check_build_tools(report: Report) -> None:
    category = "build tools"
    # Maven settings — <password> elements not wrapped in {encrypted} are plaintext
    m2_settings = HOME / ".m2" / "settings.xml"
    if m2_settings.is_file():
        content = read_text(m2_settings) or ""
        plaintext_pws = [p for p in re.findall(r"<password>([^<]+)</password>", content)
                         if p.strip() and not p.strip().startswith("{")]
        if plaintext_pws:
            report.add(ALERT, category,
                       f"{len(plaintext_pws)} plaintext Maven password(s)",
                       home_rel(m2_settings))
        else:
            report.add(OK, category, "Maven settings clean", home_rel(m2_settings))
    else:
        report.add(OK, category, "~/.m2/settings.xml absent")

    # Gradle properties — often holds signing keys, repo tokens
    gradle_props = HOME / ".gradle" / "gradle.properties"
    if gradle_props.is_file():
        _scan_file(category, gradle_props, report)
    else:
        report.add(OK, category, "~/.gradle/gradle.properties absent")

    # Composer auth.json — github-oauth, http-basic, bearer entries
    for composer_auth in (HOME / ".composer" / "auth.json",
                          HOME / ".config" / "composer" / "auth.json"):
        if not composer_auth.is_file():
            continue
        content = read_text(composer_auth) or ""
        label = home_rel(composer_auth)
        try:
            data = json.loads(content or "{}")
            # gitlab-domains is just a list of domain names that extend the default
            # gitlab.com matcher — not credential material.
            cred_keys = {"github-oauth", "gitlab-oauth", "bitbucket-oauth",
                         "http-basic", "bearer"}
            if cred_keys & set(data.keys()):
                report.add(ALERT, category, "Composer registry credentials", label)
            else:
                report.add(OK, category, "Composer auth empty", label)
        except json.JSONDecodeError:
            matches = find_known_patterns(content)
            if matches:
                report.add(ALERT, category, ", ".join(matches), label)
            else:
                report.add(WARN, category, "auth.json not valid JSON", label)
        break
    else:
        report.add(OK, category, "Composer auth.json absent")

    # SBT credentials
    sbt_creds = HOME / ".sbt" / ".credentials"
    if sbt_creds.is_file():
        content = read_text(sbt_creds) or ""
        if re.search(r"^password\s*=\s*\S", content, re.MULTILINE):
            report.add(ALERT, category, "SBT credentials with password", home_rel(sbt_creds))
        else:
            report.add(OK, category, "SBT credentials no plain password", home_rel(sbt_creds))

    # NuGet — may store plaintext API keys
    for nuget in (HOME / ".nuget" / "NuGet" / "NuGet.Config",
                  HOME / "Library" / "Application Support" / "NuGet" / "NuGet.Config"):
        if nuget.is_file():
            _scan_file(category, nuget, report)
            break

    # pip config — may embed auth in index-url
    for pip_conf in (HOME / ".config" / "pip" / "pip.conf",
                     HOME / "Library" / "Application Support" / "pip" / "pip.conf"):
        if pip_conf.is_file():
            content = read_text(pip_conf) or ""
            if re.search(r"https?://[^@/\s]+:[^@/\s]+@", content):
                report.add(ALERT, category,
                           "pip.conf index URL with embedded credentials",
                           home_rel(pip_conf))
            else:
                report.add(OK, category, "pip.conf clean", home_rel(pip_conf))
            break


def check_azure(report: Report) -> None:
    category = "Azure"
    azure_dir = HOME / ".azure"

    # MSAL token cache (modern az CLI) — contains access + refresh tokens
    msal = azure_dir / "msal_token_cache.json"
    if msal.is_file():
        size = msal.stat().st_size
        if size > 0:
            report.add(ALERT, category,
                       "MSAL token cache on disk (access + refresh tokens)",
                       home_rel(msal))
        else:
            report.add(OK, category, "MSAL token cache empty", home_rel(msal))

    for path, label in (
        (azure_dir / "accessTokens.json",               "legacy accessTokens.json"),
        (azure_dir / "servicePrincipalCredentials.json", "Service Principal credentials"),
    ):
        if not path.is_file():
            continue
        if path.stat().st_size > 0:
            report.add(ALERT, category, f"{label} on disk", home_rel(path))
        else:
            report.add(OK, category, f"{label} empty", home_rel(path))

    if not azure_dir.exists():
        report.add(OK, category, "~/.azure absent")
    elif not any(p.is_file() for p in (msal,
                                       azure_dir / "accessTokens.json",
                                       azure_dir / "servicePrincipalCredentials.json")):
        report.add(OK, category, "no token files in ~/.azure")


def check_certificates(report: Report) -> None:
    category = "certificates"
    search_dirs = [
        HOME / ".config" / "ssl",
        HOME / ".ssl",
        HOME / "certs",
        HOME / ".certs",
        HOME / "certificates",
        HOME / ".certificates",
    ]
    BINARY_CONTAINER_EXTS = {".p12", ".pfx", ".jks", ".keystore"}
    TEXT_KEY_EXTS         = {".pem", ".key"}

    key_hits: list[str] = []
    container_hits: list[str] = []
    for d in search_dirs:
        if not d.is_dir():
            continue
        for p in d.rglob("*"):
            if not p.is_file():
                continue
            ext = p.suffix.lower()
            if ext in BINARY_CONTAINER_EXTS:
                container_hits.append(home_rel(p))
            elif ext in TEXT_KEY_EXTS and starts_with_private_key_header(p):
                key_hits.append(home_rel(p))

    if key_hits:
        report.add(ALERT, category,
                   f"{len(key_hits)} private key file(s)",
                   key_hits[0] if len(key_hits) == 1 else f"{key_hits[0]} (+{len(key_hits)-1} more)")
    if container_hits:
        # Could be a private keystore or a public truststore — can't tell without parsing.
        report.add(WARN, category,
                   f"{len(container_hits)} keystore/truststore file(s) (contents not inspected)",
                   container_hits[0] if len(container_hits) == 1 else f"{container_hits[0]} (+{len(container_hits)-1} more)")
    if not key_hits and not container_hits:
        report.add(OK, category, "no private keys in certificate directories")


def check_launch_agents(report: Report) -> None:
    """Flag LaunchAgents whose binary lives in an unusual location.

    Supply-chain worms install persistent agents that poll/exfiltrate
    indefinitely after the initial install. They change names frequently,
    so the check is path-based rather than name-based: a plist that runs
    something from ~/.local/bin/, ~/.config/, /tmp/, or any hidden home
    directory is suspicious regardless of what it is called.
    """
    category = "LaunchAgents"
    agents_dir = HOME / "Library" / "LaunchAgents"
    if not agents_dir.is_dir():
        report.add(OK, category, "~/Library/LaunchAgents absent")
        return

    # Prefixes considered safe — apps from these locations are trusted.
    SAFE_PREFIXES = (
        "/Applications/",
        "/System/",
        "/usr/",
        "/opt/homebrew/",
        "/opt/local/",
        str(HOME / "Applications") + "/",
        str(HOME / "Library" / "Application Support") + "/",
        "/Library/",
    )
    # Prefixes that are always suspicious for a LaunchAgent binary.
    SUSPICIOUS_PREFIXES = (
        str(HOME / ".local") + "/",
        str(HOME / ".config") + "/",
        str(HOME / ".cache") + "/",
        "/tmp/",
        "/var/tmp/",
        "/private/tmp/",
    )
    # Any hidden directory directly under HOME is also suspicious.
    def _is_hidden_home(p: str) -> bool:
        h = str(HOME) + "/."
        return p.startswith(h)

    RECENT_DAYS = 14
    now = time.time()

    plists = sorted(agents_dir.glob("*.plist"))
    if not plists:
        report.add(OK, category, "no user LaunchAgents installed")
        return

    any_alerts = False
    for plist in plists:
        try:
            with open(plist, "rb") as fh:
                data = plistlib.load(fh)
        except Exception:
            report.add(WARN, category, "unreadable plist", home_rel(plist))
            continue

        args = data.get("ProgramArguments") or []
        program = data.get("Program") or (args[0] if args else None)
        if not program:
            # XPC service descriptors and empty stub plists (Dropbox/Google
            # create {} placeholders) legitimately have no Program key.
            if not data or data.get("MachServices") or data.get("XPCService"):
                continue
            report.add(WARN, category, "no Program key", home_rel(plist))
            continue

        age_days = (now - plist.stat().st_mtime) / 86400

        if any(program.startswith(p) for p in SUSPICIOUS_PREFIXES) or _is_hidden_home(program):
            report.add(ALERT, category,
                       f"agent runs from suspicious path",
                       f"{plist.name} → {program}")
            any_alerts = True
        elif not any(program.startswith(p) for p in SAFE_PREFIXES):
            # Unknown location (e.g. custom home bin, unusual prefix) — worth reviewing.
            report.add(WARN, category,
                       f"agent runs from non-standard path",
                       f"{plist.name} → {program}")
            any_alerts = True
        elif age_days < RECENT_DAYS:
            # Known-safe location but freshly installed — note it without alarming.
            report.add(INFO, category,
                       f"recently installed ({age_days:.0f}d ago)",
                       f"{plist.name} → {program}")

    if not any_alerts:
        report.add(OK, category, "all LaunchAgents run from known-safe paths")

    # Also scan ~/.local/bin/ for shell scripts — common malware drop point
    # (e.g. gh-token-monitor.sh from Shai-Hulud). Legitimate package managers
    # install compiled binaries there, not .sh files.
    local_bin = HOME / ".local" / "bin"
    if local_bin.is_dir():
        sh_scripts = [p for p in local_bin.iterdir()
                      if p.is_file() and p.suffix == ".sh"]
        if sh_scripts:
            for s in sh_scripts:
                report.add(ALERT, category,
                           "shell script in ~/.local/bin (common malware drop)",
                           home_rel(s))
        else:
            report.add(OK, category, "no shell scripts in ~/.local/bin")


def check_file_permissions(report: Report) -> None:
    category = "permissions"
    STRICT = [
        HOME / ".ssh" / "id_rsa",
        HOME / ".ssh" / "id_ed25519",
        HOME / ".ssh" / "id_ecdsa",
        HOME / ".ssh" / "id_dsa",
        HOME / ".netrc",
        HOME / ".pgpass",
        HOME / ".my.cnf",
        HOME / ".aws" / "credentials",
        HOME / ".vault-token",
    ]
    bad: list[str] = []
    for path in STRICT:
        if not path.exists():
            continue
        mode = path.stat().st_mode
        if mode & (stat.S_IRGRP | stat.S_IWGRP | stat.S_IXGRP |
                   stat.S_IROTH | stat.S_IWOTH | stat.S_IXOTH):
            bad.append(f"{home_rel(path)} ({oct(mode & 0o777)})")
    if bad:
        for entry in bad:
            report.add(ALERT, category, "group/world-accessible", entry)
    else:
        report.add(OK, category, "credential file permissions look correct")


# ── project .env scanning ───────────────────────────────────────────────────


SKIP_DIRS = {
    "node_modules", ".git", ".hg", ".svn", "__pycache__", ".pytest_cache",
    ".venv", "venv", ".tox", ".mypy_cache", ".ruff_cache", "vendor",
    "dist", "build", "target", ".next", ".nuxt", ".cache", ".turbo",
    ".parcel-cache", "coverage", ".gradle", ".terraform", "tmp",
    ".direnv", ".idea", ".vscode-test",
}

# .env-family file names worth scanning. .env.example/.sample/.template are
# inspected but found secrets there are downgraded to warnings.
ENV_FILE_RE = re.compile(
    r"^(?:\.envrc|\.env"
    r"(?:\.[a-zA-Z0-9._-]+)?"   # .env.local, .env.production etc.
    r")$"
)
ENV_TEMPLATE_HINT = re.compile(r"(example|sample|template|dist|default)",
                               re.IGNORECASE)


def iter_env_files(roots: Iterable[Path], max_depth: int) -> Iterator[Path]:
    seen: set[Path] = set()
    for root in roots:
        if not root.is_dir():
            continue
        root_depth = len(root.resolve().parts)
        for dirpath, dirnames, filenames in os.walk(root, followlinks=False):
            # prune
            dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
            depth = len(Path(dirpath).resolve().parts) - root_depth
            if depth >= max_depth:
                dirnames[:] = []
            for name in filenames:
                if ENV_FILE_RE.match(name):
                    p = Path(dirpath) / name
                    if p in seen:
                        continue
                    seen.add(p)
                    yield p


def classify_env_file(path: Path) -> tuple[str, str]:
    """Return (level, detail) for one .env file. Never echoes values."""
    content = read_text(path)
    if content is None:
        return WARN, "unreadable"
    assignments = list(parse_env_text(content))
    if not assignments:
        return OK, "empty / comments only"

    op_count = 0
    real_secret_count = 0
    secret_types: list[str] = []
    seen_types: set[str] = set()

    is_template_name = bool(ENV_TEMPLATE_HINT.search(path.name))

    for _lineno, name, raw in assignments:
        v = strip_quotes(raw)
        if OP_REF.match(v):
            op_count += 1
            continue
        label = env_value_is_secret(name, raw, strict=is_template_name)
        if label:
            real_secret_count += 1
            if label not in seen_types:
                secret_types.append(label)
                seen_types.add(label)

    if real_secret_count:
        summary = f"{real_secret_count} secret value(s) [{', '.join(secret_types[:3])}]"
        if is_template_name:
            # A real, strong-pattern token (e.g. AKIA…) in a committed
            # template file is still worth flagging hard.
            return ALERT, f"template-named file but {summary}"
        return ALERT, summary
    if op_count and op_count == sum(1 for _, _, r in assignments
                                    if strip_quotes(r) and not ENV_NONSECRET_VALUE.match(strip_quotes(r))
                                    and not strip_quotes(r).startswith(("/", "~/", "./", "../"))):
        return OK, f"1Password template ({op_count} op:// refs)"
    if op_count:
        return OK, f"mixed config + {op_count} op:// refs, no real secrets"
    return OK, "no real-looking secrets"


def check_env_files(report: Report, roots: list[Path], max_depth: int) -> None:
    category = ".env"
    found = list(iter_env_files(roots, max_depth))
    if not found:
        report.add(OK, category, "no .env files under scan roots",
                   ", ".join(home_rel(r) for r in roots))
        return
    for path in sorted(found):
        level, detail = classify_env_file(path)
        report.add(level, category, detail, home_rel(path))


# ── misc utilities ──────────────────────────────────────────────────────────


def dedupe(items: Iterable[Path]) -> list[Path]:
    seen: set[Path] = set()
    out: list[Path] = []
    for p in items:
        if p in seen:
            continue
        seen.add(p)
        out.append(p)
    return out


# ── orchestration ───────────────────────────────────────────────────────────


CHECKS = [
    ("SSH",             check_ssh),
    ("AWS",             check_aws),
    ("GCP",             check_gcloud),
    ("Azure",           check_azure),
    ("npm / yarn",      check_npm),
    ("GitHub / git",    check_github),
    ("Docker",          check_docker),
    ("Kubernetes",      check_kube),
    ("Vault",           check_vault),
    ("PyPI",            check_pypi),
    ("Cargo",           check_cargo),
    ("Ruby",            check_ruby),
    ("Terraform",       check_terraform),
    ("netrc",           check_netrc),
    ("databases",       check_databases),
    ("build tools",     check_build_tools),
    ("certificates",    check_certificates),
    ("misc CLIs",       check_misc_clis),
    ("shell config",    check_shell_configs),
    ("shell history",   check_shell_history),
    ("LaunchAgents",    check_launch_agents),
    ("permissions",     check_file_permissions),
]


def print_report(report: Report, quiet: bool) -> None:
    # Group by category in the order checks ran, then any straggler
    # categories from .env scanning.
    category_order: list[str] = []
    grouped: dict[str, list[Finding]] = {}
    for f in report.items:
        if f.category not in grouped:
            grouped[f.category] = []
            category_order.append(f.category)
        grouped[f.category].append(f)

    for category in category_order:
        items = grouped[category]
        visible = [f for f in items if not quiet or f.level in (ALERT, WARN)]
        if not visible:
            continue
        print(bold(category))
        for f in visible:
            line = f"  {f.glyph()} {f.label}"
            if f.detail:
                line += f"  {dim(f.detail)}"
            print(line)
        print()

    alerts = report.alerts()
    warns = report.warns()
    bar = "─" * 60
    print(dim(bar))
    if alerts:
        print(red(bold(f"  ALERT: {len(alerts)} location(s) hold real-looking secrets")))
        for f in alerts:
            print(red(f"    ✗ {f.category}: {f.label}  {dim(f.detail)}"))
        if warns:
            print(yellow(f"  plus {len(warns)} warning(s) worth a look"))
    elif warns:
        print(yellow(bold(f"  {len(warns)} warning(s), no hard alerts")))
        for f in warns:
            print(yellow(f"    ! {f.category}: {f.label}  {dim(f.detail)}"))
    else:
        print(green(bold("  All clear — no secret material exposed at rest")))
    print(dim(bar))


def report_to_json(report: Report) -> str:
    payload = {
        "alerts": [vars(f) for f in report.alerts()],
        "warnings": [vars(f) for f in report.warns()],
        "ok": [vars(f) for f in report.items if f.level == OK],
        "info": [vars(f) for f in report.items if f.level == INFO],
        "summary": {
            "alert_count": len(report.alerts()),
            "warning_count": len(report.warns()),
            "clean": not report.alerts(),
        },
    }
    return json.dumps(payload, indent=2)


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        prog="secret-scan",
        description="Audit disk for credentials a supply-chain worm could harvest.",
    )
    parser.add_argument("--quiet", action="store_true",
                        help="hide green checks; only print alerts and warnings")
    parser.add_argument("--json", action="store_true",
                        help="emit machine-readable JSON instead of styled output")
    parser.add_argument("--no-color", action="store_true",
                        help="disable ANSI colors")
    parser.add_argument("--scan-dirs", nargs="*", default=None,
                        help="project roots to walk for .env files "
                             "(default: ~/Code ~/Sources)")
    parser.add_argument("--max-depth", type=int, default=6,
                        help="max directory depth under each scan root (default 6)")
    args = parser.parse_args(argv)

    if args.no_color or args.json or not sys.stdout.isatty() \
            or os.environ.get("NO_COLOR"):
        Style.enabled = False

    if not args.scan_dirs:
        scan_dirs = [HOME / "Code", HOME / "Sources"]
    else:
        scan_dirs = [Path(p).expanduser() for p in args.scan_dirs]

    report = Report()
    for _name, fn in CHECKS:
        try:
            fn(report)
        except Exception as exc:  # noqa: BLE001
            report.add(WARN, _name, f"check raised: {exc!r}")
    try:
        check_env_files(report, scan_dirs, args.max_depth)
    except Exception as exc:  # noqa: BLE001
        report.add(WARN, ".env", f"scan raised: {exc!r}")

    if args.json:
        print(report_to_json(report))
    else:
        print_report(report, quiet=args.quiet)

    return 1 if report.alerts() else 0


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv[1:]))
    except KeyboardInterrupt:
        sys.exit(130)
