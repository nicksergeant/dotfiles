#!/usr/bin/env node

import { execSync, spawnSync } from 'child_process';

function convertToHTML(markdown) {
  let html = '<html><head><meta charset="UTF-8"></head><body style="background-color: white;">\n';
  const lines = markdown.split('\n');
  let inList = false;
  let inCodeBlock = false;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const prevLine = i > 0 ? lines[i - 1] : '';
    const nextLine = i < lines.length - 1 ? lines[i + 1] : '';

    // Handle code fence markers
    if (line.trim().match(/^```/)) {
      if (!inCodeBlock) {
        inCodeBlock = true;
        html += '<blockquote>\n';
      } else {
        html += '</blockquote>\n';
        inCodeBlock = false;
      }
      continue;
    }

    // Code block content as blockquote paragraphs
    if (inCodeBlock) {
      if (!line.trim()) {
        // Auto-close on blank line (handles unclosed fences)
        html += '</blockquote>\n';
        inCodeBlock = false;
        continue;
      }
      html += `<p>${escapeHTML(line)}</p>\n`;
      continue;
    }

    // Skip horizontal rules
    if (line.trim().match(/^-{3,}$|^\*{3,}$|^_{3,}$/)) {
      continue;
    }

    // Lists: both `- item` and `1. item` syntax render as bulleted lists.
    // Bullets nest more cleanly and feel less aggressive than numerals.
    const listMatch =
      line.match(/^(\s*)[-*]\s+(.+)$/) || line.match(/^(\s*)\d+\.\s+(.+)$/);

    if (listMatch) {
      if (!inList) {
        html += '<ul>\n';
        inList = true;
      }
      html += `<li>${processInlineFormatting(listMatch[2])}</li>\n`;
      continue;
    }

    if (inList) {
      html += '</ul>\n';
      inList = false;
    }

    // Explicit markdown headers (with optional leading whitespace)
    if (line.match(/^\s*#{1,6}\s+/)) {
      const text = line.replace(/^\s*#{1,6}\s+/, '');
      html += `<p><strong>${escapeHTML(text)}</strong></p>\n`;
      continue;
    }

    // Skip blank lines — adjacent `<p>` tags already provide vertical spacing,
    // so emitting `<p></p>` here would double-space everything.
    if (!line.trim()) {
      continue;
    }

    // Implicit headers: short lines with blank lines before and after,
    // excluding greetings/closings (lines ending in `,`).
    const trimmed = line.trim();
    const isShort = trimmed.length < 80;
    const prevEmpty = !prevLine.trim();
    const nextEmpty = !nextLine.trim() || nextLine.match(/^(\s*)[-*\d]/);
    if (isShort && prevEmpty && nextEmpty && !trimmed.match(/[.!?,]$/)) {
      html += `<p><strong>${processInlineFormatting(trimmed)}</strong></p>\n`;
      continue;
    }

    html += `<p>${processInlineFormatting(line.trim())}</p>\n`;
  }

  if (inList) html += '</ul>\n';
  if (inCodeBlock) html += '</blockquote>\n';
  html += '</body></html>';
  return html;
}

function processInlineFormatting(text) {
  const codes = [];
  let processed = text.replace(/`([^`\n]+?)`/g, (_, code) => {
    codes.push(code);
    return `<<<CODE_${codes.length - 1}>>>`;
  });

  processed = processed
    .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>')
    .replace(/\*\*([^\*\n]+?)\*\*/g, '<strong>$1</strong>')
    .replace(/(?<!\w)__([^_\n]+?)__(?!\w)/g, '<strong>$1</strong>')
    .replace(/\*([^\*\n]+?)\*/g, '<em>$1</em>')
    .replace(/(?<!\w)_([^_\n]+?)_(?!\w)/g, '<em>$1</em>')
    .replace(/<<<CODE_(\d+)>>>/g, (_, index) => `<code>${escapeHTML(codes[index])}</code>`)
    .replace(/&(?!(amp|lt|gt|quot|#\d+);)/g, '&amp;');

  return processed;
}

function escapeHTML(text) {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

// Strip font/color tables and refs so paste adopts the destination's default
// font instead of bringing its own (avoiding Helvetica/Times New Roman in Mail).
function cleanRTF(rtf) {
  for (const prefix of ['{\\fonttbl', '{\\colortbl', '{\\*\\expandedcolortbl']) {
    const start = rtf.indexOf(prefix);
    if (start === -1) continue;
    let depth = 1;
    let i = start + prefix.length;
    while (i < rtf.length && depth > 0) {
      if (rtf[i] === '{') depth++;
      else if (rtf[i] === '}') depth--;
      i++;
    }
    rtf = rtf.substring(0, start) + rtf.substring(i);
  }
  return rtf
    .replace(/\\f\d+ ?/g, '')
    .replace(/\\fs\d+ ?/g, '')
    .replace(/\\cf\d+ ?/g, '')
    .replace(/\\cb\d+ ?/g, '');
}

try {
  const markdown = execSync('pbpaste', { encoding: 'utf8' });
  if (!markdown.trim()) {
    console.error('Clipboard is empty');
    process.exit(1);
  }

  const html = convertToHTML(markdown);
  const rtfResult = spawnSync('textutil', ['-stdin', '-format', 'html', '-convert', 'rtf', '-stdout'], {
    encoding: 'utf8',
    input: html
  });

  if (rtfResult.error) throw rtfResult.error;

  const rtfData = cleanRTF(rtfResult.stdout);
  const htmlHex = Buffer.from(html).toString('hex');
  const rtfHex = Buffer.from(rtfData).toString('hex');
  const plainText = markdown
    .replace(/\\/g, '\\\\')
    .replace(/"/g, '\\"')
    .replace(/\n/g, '\\n');
  const appleScript = `
    set the clipboard to {«class HTML»:«data HTML${htmlHex}», «class RTF »:«data RTF ${rtfHex}», string:"${plainText}"}
  `;

  const asResult = spawnSync('osascript', ['-e', appleScript]);
  if (asResult.error) throw asResult.error;

  console.log('OK');
} catch (error) {
  console.error('Error:', error.message);
  process.exit(1);
}
