#!/usr/bin/env python3
"""Preview a Claude conversation JSONL file for fzf."""

import json
import os
import sys
from datetime import datetime, timezone


def extract_text(content):
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = []
        for block in content:
            if not isinstance(block, dict):
                continue
            if block.get("type") == "text":
                parts.append(block["text"])
            elif block.get("type") == "tool_result":
                t = block.get("content", "")
                if isinstance(t, str) and t:
                    parts.append(t[:200])
            elif block.get("type") == "tool_use":
                parts.append(f"[tool: {block.get('name', '?')}]")
        return "\n".join(parts)
    return str(content)[:500]


def format_ts(ts):
    try:
        if isinstance(ts, (int, float)):
            if ts > 1e12:
                ts /= 1000
            dt = datetime.fromtimestamp(ts, tz=timezone.utc)
        elif isinstance(ts, str) and ts:
            dt = datetime.fromisoformat(ts.replace("Z", "+00:00"))
        else:
            return ""
        secs = int((datetime.now(timezone.utc) - dt).total_seconds())
        if secs < 60: return "now"
        if secs < 3600: return f"{secs // 60}m"
        if secs < 86400: return f"{secs // 3600}h"
        if secs < 604800: return f"{secs // 86400}d"
        if secs < 2592000: return f"{secs // 604800}w"
        return f"{secs // 2592000}mo"
    except Exception:
        return ""


def print_msg(role, text, ts):
    time_str = format_ts(ts)
    if role == "user":
        label = f"\033[1;34m> You\033[0m  \033[38;5;245m{time_str}\033[0m"
    else:
        label = f"\033[1;32m> Claude\033[0m  \033[38;5;245m{time_str}\033[0m"
    print(label)
    if len(text) > 600:
        text = text[:600] + "..."
    print(text)
    print()


def main():
    if len(sys.argv) < 2:
        sys.exit(1)

    filepath = sys.argv[1]
    messages = []
    session_id = os.path.basename(filepath).replace(".jsonl", "")
    cwd = None
    title = None

    with open(filepath) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                d = json.loads(line)
            except Exception:
                continue

            if not cwd and d.get("cwd"):
                cwd = d["cwd"]

            if d.get("type") == "custom-title":
                title = d.get("customTitle")

            if d.get("type") not in ("user", "assistant"):
                continue

            text = extract_text(d.get("message", {}).get("content", "")).strip()
            if not text:
                continue

            messages.append((d["type"], text, d.get("timestamp", "")))

    # Header
    project = os.path.basename(cwd) if cwd else "unknown"
    name = title or session_id
    print(f"\033[1m{project}\033[0m  \033[38;5;245m{name}\033[0m")
    print()

    limit = 100
    recent = messages[-limit:]

    for role, text, ts in reversed(recent):
        print_msg(role, text, ts)

    if len(messages) > limit:
        skipped = len(messages) - limit - 1
        print(f"\033[38;5;245m... {skipped} other messages ...\033[0m")
        print()
        role, text, ts = messages[0]
        print_msg(role, text, ts)


if __name__ == "__main__":
    main()
