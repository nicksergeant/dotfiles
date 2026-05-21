#!/usr/bin/env python3
"""md2richtext: convert clipboard markdown to rich text (HTML + RTF + plain).

Reads markdown from pbpaste, converts to HTML, runs that through textutil
to produce RTF, strips the RTF font/color tables so the destination app
applies its own composition font, then writes HTML + cleaned RTF + plain
text back to the pasteboard via osascript.
"""

from __future__ import annotations

import re
import subprocess
import sys
from binascii import hexlify


def escape_html(text: str) -> str:
    return (
        text.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
    )


def process_inline_formatting(text: str) -> str:
    codes: list[str] = []

    def _stash_code(match: re.Match[str]) -> str:
        codes.append(match.group(1))
        return f"<<<CODE_{len(codes) - 1}>>>"

    text = re.sub(r"`([^`\n]+?)`", _stash_code, text)
    text = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r'<a href="\2">\1</a>', text)
    text = re.sub(r"\*\*([^\*\n]+?)\*\*", r"<strong>\1</strong>", text)
    text = re.sub(r"(?<!\w)__([^_\n]+?)__(?!\w)", r"<strong>\1</strong>", text)
    text = re.sub(r"\*([^\*\n]+?)\*", r"<em>\1</em>", text)
    text = re.sub(r"(?<!\w)_([^_\n]+?)_(?!\w)", r"<em>\1</em>", text)

    def _restore_code(match: re.Match[str]) -> str:
        return f"<code>{escape_html(codes[int(match.group(1))])}</code>"

    text = re.sub(r"<<<CODE_(\d+)>>>", _restore_code, text)
    text = re.sub(r"&(?!(?:amp|lt|gt|quot|#\d+);)", "&amp;", text)
    return text


def convert_to_html(markdown: str) -> str:
    html = '<html><head><meta charset="UTF-8"></head><body style="background-color: white;">\n'
    lines = markdown.split("\n")
    in_list = False
    in_code_block = False

    for i, line in enumerate(lines):
        prev_line = lines[i - 1] if i > 0 else ""
        next_line = lines[i + 1] if i < len(lines) - 1 else ""

        # Handle code fence markers
        if re.match(r"^```", line.strip()):
            if not in_code_block:
                in_code_block = True
                html += "<blockquote>\n"
            else:
                html += "</blockquote>\n"
                in_code_block = False
            continue

        # Code block content as blockquote paragraphs
        if in_code_block:
            if not line.strip():
                # Auto-close on blank line (handles unclosed fences)
                html += "</blockquote>\n"
                in_code_block = False
                continue
            html += f"<p>{escape_html(line)}</p>\n"
            continue

        # Skip horizontal rules
        if re.match(r"^-{3,}$|^\*{3,}$|^_{3,}$", line.strip()):
            continue

        # Lists: both `- item` and `1. item` syntax render as bulleted lists.
        # Bullets nest more cleanly and feel less aggressive than numerals.
        list_match = re.match(r"^(\s*)[-*]\s+(.+)$", line) or re.match(
            r"^(\s*)\d+\.\s+(.+)$", line
        )
        if list_match:
            if not in_list:
                html += "<ul>\n"
                in_list = True
            html += f"<li>{process_inline_formatting(list_match.group(2))}</li>\n"
            continue

        if in_list:
            html += "</ul>\n"
            in_list = False

        # Explicit markdown headers (with optional leading whitespace)
        if re.match(r"^\s*#{1,6}\s+", line):
            text = re.sub(r"^\s*#{1,6}\s+", "", line)
            html += f"<p><strong>{escape_html(text)}</strong></p>\n"
            continue

        # Skip blank lines; adjacent <p> tags already provide vertical spacing,
        # so emitting <p></p> here would double-space everything.
        if not line.strip():
            continue

        # Implicit headers: short lines with blank lines before and after,
        # excluding greetings/closings (lines ending in `,`).
        trimmed = line.strip()
        is_short = len(trimmed) < 80
        prev_empty = not prev_line.strip()
        next_empty = bool(
            not next_line.strip() or re.match(r"^(\s*)[-*\d]", next_line)
        )
        if (
            is_short
            and prev_empty
            and next_empty
            and not re.search(r"[.!?,]$", trimmed)
        ):
            html += f"<p><strong>{process_inline_formatting(trimmed)}</strong></p>\n"
            continue

        html += f"<p>{process_inline_formatting(line.strip())}</p>\n"

    if in_list:
        html += "</ul>\n"
    if in_code_block:
        html += "</blockquote>\n"
    html += "</body></html>"
    return html


def clean_rtf(rtf: str) -> str:
    """Strip font/color tables and refs so paste adopts the destination's
    default font instead of bringing its own (avoiding Helvetica/Times New
    Roman in Mail)."""
    for prefix in ("{\\fonttbl", "{\\colortbl", "{\\*\\expandedcolortbl"):
        start = rtf.find(prefix)
        if start == -1:
            continue
        depth = 1
        i = start + len(prefix)
        while i < len(rtf) and depth > 0:
            ch = rtf[i]
            if ch == "{":
                depth += 1
            elif ch == "}":
                depth -= 1
            i += 1
        rtf = rtf[:start] + rtf[i:]

    rtf = re.sub(r"\\f\d+ ?", "", rtf)
    rtf = re.sub(r"\\fs\d+ ?", "", rtf)
    rtf = re.sub(r"\\cf\d+ ?", "", rtf)
    rtf = re.sub(r"\\cb\d+ ?", "", rtf)
    return rtf


def main() -> int:
    try:
        markdown = subprocess.run(
            ["pbpaste"], capture_output=True, text=True, check=True
        ).stdout
    except (subprocess.CalledProcessError, FileNotFoundError) as exc:
        print(f"Error: pbpaste failed: {exc}", file=sys.stderr)
        return 1

    if not markdown.strip():
        print("Clipboard is empty", file=sys.stderr)
        return 1

    html = convert_to_html(markdown)

    try:
        rtf_data = clean_rtf(
            subprocess.run(
                ["textutil", "-stdin", "-format", "html", "-convert", "rtf", "-stdout"],
                input=html,
                capture_output=True,
                text=True,
                check=True,
            ).stdout
        )
    except (subprocess.CalledProcessError, FileNotFoundError) as exc:
        print(f"Error: textutil failed: {exc}", file=sys.stderr)
        return 1

    html_hex = hexlify(html.encode("utf-8")).decode()
    rtf_hex = hexlify(rtf_data.encode("utf-8")).decode()
    plain_text = markdown.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")

    apple_script = (
        f"set the clipboard to {{«class HTML»:«data HTML{html_hex}»,"
        f' «class RTF »:«data RTF {rtf_hex}», string:"{plain_text}"}}'
    )

    try:
        subprocess.run(["osascript", "-e", apple_script], check=True)
    except (subprocess.CalledProcessError, FileNotFoundError) as exc:
        print(f"Error: osascript failed: {exc}", file=sys.stderr)
        return 1

    print("OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
