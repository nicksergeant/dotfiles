#!/usr/bin/env node

import { execSync, spawnSync } from 'child_process';

function convertToHTML(markdown) {
  let html = '<html><head><meta charset="UTF-8"></head><body style="background-color: white;">\n';
  const lines = markdown.split('\n');
  let inList = false;
  let listType = null;
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
        html += '</blockquote>\n<p></p>\n';
        inCodeBlock = false;
        continue;
      }
      html += `<p>${escapeHTML(line)}</p>\n`;
      continue;
    }

    const unorderedMatch = line.match(/^(\s*)[-*]\s+(.+)$/);
    const orderedMatch = line.match(/^(\s*)\d+\.\s+(.+)$/);

    // Skip horizontal rules
    if (line.trim().match(/^-{3,}$|^\*{3,}$|^_{3,}$/)) {
      continue;
    }

    if (unorderedMatch) {
      if (!inList || listType !== 'ul') {
        if (inList) html += `</${listType}>\n`;
        html += '<ul>\n';
        inList = true;
        listType = 'ul';
      }
      html += `<li>${processInlineFormatting(unorderedMatch[2])}</li>\n`;
      continue;
    }

    if (orderedMatch) {
      if (!inList || listType !== 'ol') {
        if (inList) html += `</${listType}>\n`;
        html += '<ol>\n';
        inList = true;
        listType = 'ol';
      }
      html += `<li>${processInlineFormatting(orderedMatch[2])}</li>\n`;
      continue;
    }

    if (inList && !unorderedMatch && !orderedMatch) {
      html += `</${listType}>\n`;
      inList = false;
      listType = null;
    }

    // Explicit markdown headers (with optional leading whitespace)
    if (line.match(/^\s*#{1,6}\s+/)) {
      const text = line.replace(/^\s*#{1,6}\s+/, '');
      html += `<p><strong>${escapeHTML(text)}</strong></p>\n`;
      continue;
    }

    if (!line.trim()) {
      html += '<p></p>\n';
      continue;
    }

    // Implicit headers: short lines with blank lines before and after
    const trimmed = line.trim();
    const isShort = trimmed.length < 80;
    const prevEmpty = !prevLine.trim();
    const nextEmpty = !nextLine.trim() || nextLine.match(/^(\s*)[-*\d]/);
    if (isShort && prevEmpty && nextEmpty && !trimmed.match(/[.!?]$/)) {
      html += `<p><strong>${processInlineFormatting(trimmed)}</strong></p>\n`;
      continue;
    }

    html += `<p>${processInlineFormatting(line.trim())}</p>\n`;
  }

  if (inList) html += `</${listType}>\n`;
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
    .replace(/__([^_\n]+?)__/g, '<strong>$1</strong>')
    .replace(/\*([^\*\n]+?)\*/g, '<em>$1</em>')
    .replace(/_([^_\n]+?)_/g, '<em>$1</em>')
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

  const rtfData = rtfResult.stdout;
  const appleScript = `
    set the clipboard to {«class RTF »:«data RTF ${Buffer.from(rtfData).toString('hex')}», string:"${markdown.replace(/\\/g, '\\\\').replace(/"/g, '\\"').replace(/\n/g, '\\n')}"}
  `;

  const asResult = spawnSync('osascript', ['-e', appleScript]);
  if (asResult.error) throw asResult.error;

  console.log('OK');
} catch (error) {
  console.error('Error:', error.message);
  process.exit(1);
}
