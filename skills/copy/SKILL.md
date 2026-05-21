---
name: copy
description: Copy the most recent assistant output to the clipboard as rich text (HTML+RTF) via ~/Sources/dotfiles/scripts/md2richtext.js. INVOKE this skill whenever the user types `copy()` (literal, with parens) in a message — alone or paired with brief clarification like "copy() the draft email above". The script preserves bold/italic/lists/links/code and strips the RTF font table so paste adopts the destination app's current composition font (Mail.app, Slack, Notion, etc.).
---

# copy

Default target: the immediately preceding assistant turn's user-visible text — the markdown that rendered to the user.

## Workflow

1. **Pick the content.** Default to the previous assistant turn. If that turn produced multiple distinct artifacts (e.g., a code change *and* a draft message), ask the user which one before running — don't guess silently.

2. **Strip non-content meta-chatter.** Don't copy framing like "ready to commit", "want me to do X?", or trailing status lines. Just the substantive content the user is asking to copy.

3. **Pipe to pbcopy via a quoted heredoc, then run the conversion script.** The quoted delimiter (`'COPY_EOF'`) prevents the shell from interpreting backticks, `$`, or backslashes in the content:

```bash
cat <<'COPY_EOF' | pbcopy
<the markdown content, verbatim>
COPY_EOF
~/Sources/dotfiles/scripts/md2richtext.js
```

4. **Confirm.** One short line: "Copied to clipboard as rich text."

## How the script works

`md2richtext.js` reads markdown from `pbpaste`, converts to HTML, runs it through `textutil` to produce RTF, strips the RTF font/color tables and `\f/\fs/\cf/\cb` references, and replaces the clipboard with both HTML and RTF representations plus a plain-text fallback.

Font-stripping means the destination app uses its own current composition font on paste — there is no need to specify fonts in the output. Pasting into Mail.app picks up whatever you've set in Mail's preferences; pasting into Slack picks up Slack's font; pasting into a plain-text-only app gets the original markdown.
