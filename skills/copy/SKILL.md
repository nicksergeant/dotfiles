---
name: copy
description: Copy the most recent assistant output to the clipboard as rich text (HTML + RTF + plain text) via ~/Sources/dotfiles/scripts/md2richtext.js. INVOKE this skill whenever the user types `copy()` (literal, with parens) in a message, alone or paired with brief clarification like "copy() the draft email above". The script preserves bold/italic/lists/links/code; the HTML representation lets Mail.app, Notion, etc. inherit their own compose font, while the RTF representation covers TextEdit, Slack, and other RTF-first targets.
---

# copy

Default target: the immediately preceding assistant turn's user-visible text, the markdown that rendered to the user.

## Workflow

1. **Pick the content.** Default to the previous assistant turn. If that turn produced multiple distinct artifacts (e.g., a code change *and* a draft message), ask the user which one before running; don't guess silently.

2. **Strip non-content meta-chatter.** Don't copy framing like "ready to commit", "want me to do X?", or trailing status lines. Just the substantive content the user is asking to copy.

3. **Use bold sparingly.** Reserve `**bold**` for actual section headings, places where a reader needs a visual landmark to navigate a longer message. Do *not* bold greetings (`Hi Susie,`), closings (`Thanks,`), inline emphasis on a single word, or section intros that are immediately followed by a list. Plain text is the default; bold is a navigational tool, not a flourish.

4. **Clean up AI/robotic phrasing without changing substance.** Strip em dashes (—) by replacing them with commas, periods, semicolons, parentheses, or a small rewrite. Quietly fix hedge openers ("just to confirm", "I want to make sure", "I'd love to"), boilerplate closings ("looking forward to..."), over-emphatic adjectives ("crucial", "robust", "seamless"), and verbs LLMs lean on ("delve", "underscore", "elucidate"). Preserve every fact, decision, and nuance of the user's intent. The goal is texture only: it should sound like a person wrote it, not a chatbot.

5. **Pipe to pbcopy via a quoted heredoc, then run the conversion script.** The quoted delimiter (`'COPY_EOF'`) prevents the shell from interpreting backticks, `$`, or backslashes in the content:

```bash
cat <<'COPY_EOF' | pbcopy
<the markdown content, verbatim>
COPY_EOF
~/Sources/dotfiles/scripts/md2richtext.js
```

6. **Confirm.** One short line: "Copied to clipboard as rich text."

## How the script works

`md2richtext.js` reads markdown from `pbpaste`, converts to HTML, runs it through `textutil` to produce RTF, strips the RTF font/color tables and `\f/\fs/\cf/\cb` references, and replaces the clipboard with three representations: HTML (`«class HTML»`), RTF (`«class RTF »`), and plain text (`string`).

Pasting into Mail.app or Notion uses the HTML path, which has no `font-family` declared, so the destination app applies its own composition font (Mail's "Message font" preference, etc.). Pasting into a TextEdit/RTF-only target uses the cleaned RTF. Pasting into a plain-text-only target gets the original markdown.

Both `- item` and `1. item` syntax render as bulleted lists. The user almost always prefers bullets over numerals (bullets nest more cleanly and feel less aggressive), so the script normalizes both shapes. If a numbered list is genuinely needed, prefix each line inline (e.g., "Step 1: ...") rather than relying on markdown ordered-list syntax.
