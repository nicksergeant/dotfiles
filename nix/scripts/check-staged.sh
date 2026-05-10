#!/usr/bin/env bash
#
# Run lint/format/spell checks on staged files. Invoked from the pre-commit
# hook (.githooks/pre-commit) via `nix develop --command`, which loads tools
# from the flake's devShell (nixfmt, statix, deadnix, shellcheck, typos —
# all pinned via flake.lock → nixpkgs).
#
# Manual invocation:
#   cd nix && nix develop --command bash scripts/check-staged.sh
#
# Skip individual commits with `git commit --no-verify` if you really need to.

set -e

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

# Identify staged files by category.
nix_files=$(git diff --cached --name-only --diff-filter=ACMR | grep -E '\.nix$' || true)

# Shell scripts: .sh extension OR bash/sh shebang on the first line. zsh
# scripts are deliberately excluded — shellcheck's zsh support is partial
# and produces noisy false positives on legitimate zsh idioms.
sh_files=$(
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    case "$f" in
      *.sh) echo "$f" ;;
      *)
        if [ -f "$f" ] && head -c 1024 "$f" 2>/dev/null | head -n1 \
             | grep -qE '^#!.*(\bbash\b|/bin/sh\b)'; then
          echo "$f"
        fi
        ;;
    esac
  done < <(git diff --cached --name-only --diff-filter=ACMR)
)

# typos handles both code and prose; run on every staged text file (skip
# binaries via well-known extensions defensively).
all_files=$(git diff --cached --name-only --diff-filter=ACMR \
            | grep -vE '\.(png|jpg|jpeg|gif|webp|ico|pdf|woff2?|ttf|otf|eot|icns|so|dylib)$' \
            || true)

# ──────────────────────────────────────────────────────────────────────
# Nix: format check + lint + dead-code detection
# ──────────────────────────────────────────────────────────────────────
if [ -n "$nix_files" ]; then
  echo "→ nixfmt --check (format compliance)"
  echo "$nix_files" | xargs nixfmt --check

  echo "→ statix check (anti-pattern lint)"
  echo "$nix_files" | xargs -n1 statix check

  echo "→ deadnix --fail (dead code detection)"
  echo "$nix_files" | xargs deadnix --fail
fi

# ──────────────────────────────────────────────────────────────────────
# Shell scripts: shellcheck
# ──────────────────────────────────────────────────────────────────────
if [ -n "$sh_files" ]; then
  echo "→ shellcheck"
  echo "$sh_files" | xargs shellcheck
fi

# ──────────────────────────────────────────────────────────────────────
# All files: typos
# ──────────────────────────────────────────────────────────────────────
if [ -n "$all_files" ]; then
  echo "→ typos (spell check)"
  echo "$all_files" | xargs typos
fi
