#!/usr/bin/env node

import { execSync, spawnSync } from 'child_process';

function convertToHTML(markdown) {
  let html = '<html><body style="background-color: white;">\n';
  const lines = markdown.split('\n');
  let inList = false;
  let listType = null;

  for (const line of lines) {
    const unorderedMatch = line.match(/^(\s*)[-*]\s+(.+)$/);
    const orderedMatch = line.match(/^(\s*)\d+\.\s+(.+)$/);

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

    if (line.match(/^#{1,6}\s+/)) {
      const text = line.replace(/^#{1,6}\s+/, '');
      html += `<p><strong>${escapeHTML(text)}</strong></p>\n`;
      continue;
    }

    if (!line.trim()) {
      html += '<p></p>\n';
      continue;
    }

    html += `<p>${processInlineFormatting(line)}</p>\n`;
  }

  if (inList) html += `</${listType}>\n`;
  html += '</body></html>';
  return html;
}

function processInlineFormatting(text) {
  const codes = [];
  let processed = text.replace(/`([^`\n]+?)`/g, (match, code) => {
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
  const rtfResult = spawnSync('sh', ['-c', `echo ${JSON.stringify(html)} | textutil -stdin -format html -convert rtf -stdout`], {
    encoding: 'utf8'
  });

  if (rtfResult.error) throw rtfResult.error;

  const rtfData = rtfResult.stdout;
  const appleScript = `
    set the clipboard to {«class RTF »:«data RTF ${Buffer.from(rtfData).toString('hex')}», string:"${markdown.replace(/"/g, '\\"').replace(/\n/g, '\\n')}"}
  `;

  const asResult = spawnSync('osascript', ['-e', appleScript]);
  if (asResult.error) throw asResult.error;

  console.log('OK');
} catch (error) {
  console.error('Error:', error.message);
  process.exit(1);
}
