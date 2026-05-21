import { test, describe } from 'node:test';
import assert from 'node:assert/strict';
import {
  convertToHTML,
  processInlineFormatting,
  escapeHTML,
  cleanRTF,
} from './md2richtext.js';

// Strip the surrounding <html><head>...<body ...> wrapper so individual
// tests can focus on the meaningful structure.
function body(html) {
  return html
    .replace(
      /^<html><head><meta charset="UTF-8"><\/head><body style="background-color: white;">\n/,
      ''
    )
    .replace(/<\/body><\/html>$/, '')
    .trim();
}

describe('escapeHTML', () => {
  test('escapes ampersand', () => {
    assert.equal(escapeHTML('a & b'), 'a &amp; b');
  });

  test('escapes angle brackets', () => {
    assert.equal(escapeHTML('<div>'), '&lt;div&gt;');
  });

  test('escapes double quotes', () => {
    assert.equal(escapeHTML('say "hi"'), 'say &quot;hi&quot;');
  });

  test('escapes ampersand before other entities (no double-encoding)', () => {
    assert.equal(escapeHTML('<a>&</a>'), '&lt;a&gt;&amp;&lt;/a&gt;');
  });

  test('passes plain text through unchanged', () => {
    assert.equal(escapeHTML('hello world'), 'hello world');
  });
});

describe('processInlineFormatting', () => {
  test('wraps **bold** in <strong>', () => {
    assert.equal(processInlineFormatting('**bold**'), '<strong>bold</strong>');
  });

  test('wraps __bold__ in <strong>', () => {
    assert.equal(processInlineFormatting('__bold__'), '<strong>bold</strong>');
  });

  test('wraps *italic* in <em>', () => {
    assert.equal(processInlineFormatting('*italic*'), '<em>italic</em>');
  });

  test('wraps standalone _italic_ in <em>', () => {
    assert.equal(processInlineFormatting('_italic_'), '<em>italic</em>');
  });

  test('does NOT italicize intra-word underscores (source_url)', () => {
    assert.equal(processInlineFormatting('source_url'), 'source_url');
  });

  test('does NOT italicize intra-word underscores when surrounded by other text', () => {
    assert.equal(
      processInlineFormatting('the source_url field'),
      'the source_url field'
    );
  });

  test('preserves identifiers with multiple underscores', () => {
    assert.equal(
      processInlineFormatting('Use document_url_field here'),
      'Use document_url_field here'
    );
  });

  test('wraps inline `code` in <code>', () => {
    assert.equal(processInlineFormatting('`foo`'), '<code>foo</code>');
  });

  test('escapes HTML entities inside inline code', () => {
    assert.equal(
      processInlineFormatting('`<div>`'),
      '<code>&lt;div&gt;</code>'
    );
  });

  test('preserves underscores inside inline code', () => {
    assert.equal(
      processInlineFormatting('`source_url`'),
      '<code>source_url</code>'
    );
  });

  test('renders [text](url) as <a>', () => {
    assert.equal(
      processInlineFormatting('[link](https://example.com)'),
      '<a href="https://example.com">link</a>'
    );
  });

  test('handles mixed inline formatting', () => {
    assert.equal(
      processInlineFormatting('Use **`source_url`** for the API'),
      'Use <strong><code>source_url</code></strong> for the API'
    );
  });

  test('escapes bare & but not existing entities', () => {
    assert.equal(processInlineFormatting('a & b'), 'a &amp; b');
    assert.equal(processInlineFormatting('a &amp; b'), 'a &amp; b');
    assert.equal(processInlineFormatting('a &#123; b'), 'a &#123; b');
  });
});

describe('convertToHTML', () => {
  test('wraps a single paragraph', () => {
    assert.equal(body(convertToHTML('Hello world.')), '<p>Hello world.</p>');
  });

  test('separates paragraphs without emitting empty <p></p>', () => {
    const html = body(convertToHTML('First paragraph.\n\nSecond paragraph.'));
    assert.equal(html, '<p>First paragraph.</p>\n<p>Second paragraph.</p>');
    assert.ok(!html.includes('<p></p>'), 'should not contain empty paragraphs');
  });

  test('collapses multiple blank lines between paragraphs to one separator', () => {
    const html = body(
      convertToHTML('First paragraph.\n\n\n\nSecond paragraph.')
    );
    assert.ok(!html.includes('<p></p>'), 'should not contain empty paragraphs');
  });

  test('converts unordered lists', () => {
    const html = body(convertToHTML('- one\n- two\n- three'));
    assert.equal(
      html,
      '<ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>'
    );
  });

  test('converts numbered lists to bulleted (normalization)', () => {
    const html = body(convertToHTML('1. one\n2. two\n3. three'));
    assert.equal(
      html,
      '<ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>'
    );
    assert.ok(!html.includes('<ol'), 'should never emit an <ol>');
  });

  test('mixed numbered and bulleted items collapse to a single <ul>', () => {
    const html = body(convertToHTML('1. numbered\n- bulleted\n2. numbered'));
    assert.equal(
      html,
      '<ul>\n<li>numbered</li>\n<li>bulleted</li>\n<li>numbered</li>\n</ul>'
    );
  });

  test('closes list when followed by a paragraph', () => {
    const html = body(convertToHTML('- item\n\nParagraph after list.'));
    assert.equal(
      html,
      '<ul>\n<li>item</li>\n</ul>\n<p>Paragraph after list.</p>'
    );
  });

  test('treats explicit # heading as bold paragraph', () => {
    assert.equal(
      body(convertToHTML('# My Heading')),
      '<p><strong>My Heading</strong></p>'
    );
  });

  test('treats ## heading as bold paragraph', () => {
    assert.equal(
      body(convertToHTML('## Subheading')),
      '<p><strong>Subheading</strong></p>'
    );
  });

  test('bolds implicit headers (short line, blank-bounded, no terminator)', () => {
    const html = body(
      convertToHTML('Intro paragraph.\n\nSection Heading\n\nNext paragraph.')
    );
    assert.ok(
      html.includes('<p><strong>Section Heading</strong></p>'),
      `expected implicit header bolded; got: ${html}`
    );
  });

  test('does NOT bold a greeting ending in a comma', () => {
    const html = body(convertToHTML('Hi Susie,\n\nNext paragraph.'));
    assert.ok(
      html.includes('<p>Hi Susie,</p>'),
      `greeting should be plain; got: ${html}`
    );
    assert.ok(
      !html.includes('<strong>Hi Susie,</strong>'),
      'greeting should not be bolded'
    );
  });

  test('does NOT bold a closing ending in a comma', () => {
    const html = body(convertToHTML('Some text.\n\nThanks,\n\nNick'));
    assert.ok(
      html.includes('<p>Thanks,</p>'),
      `closing should be plain; got: ${html}`
    );
    assert.ok(
      !html.includes('<strong>Thanks,</strong>'),
      'closing should not be bolded'
    );
  });

  test('does NOT bold lines ending in . ! or ?', () => {
    const html1 = body(convertToHTML('Intro.\n\nA short period sentence.\n\nNext.'));
    assert.ok(!html1.includes('<strong>A short period sentence.'));

    const html2 = body(convertToHTML('Intro.\n\nWhat about this?\n\nNext.'));
    assert.ok(!html2.includes('<strong>What about this?'));

    const html3 = body(convertToHTML('Intro.\n\nWow!\n\nNext.'));
    assert.ok(!html3.includes('<strong>Wow!'));
  });

  test('still bolds a short line ending with a colon (treated as section heading)', () => {
    const html = body(
      convertToHTML('Intro paragraph.\n\nWhat we built:\n\n- one\n- two')
    );
    assert.ok(
      html.includes('<p><strong>What we built:</strong></p>'),
      `expected colon-ending header bolded; got: ${html}`
    );
  });

  test('skips horizontal rules', () => {
    const html = body(convertToHTML('Before.\n\n---\n\nAfter.'));
    assert.equal(html, '<p>Before.</p>\n<p>After.</p>');
  });

  test('renders fenced code as <blockquote> paragraphs', () => {
    const html = body(
      convertToHTML('```\nconst x = 1;\nconst y = 2;\n```')
    );
    assert.equal(
      html,
      '<blockquote>\n<p>const x = 1;</p>\n<p>const y = 2;</p>\n</blockquote>'
    );
  });

  test('escapes HTML entities inside fenced code', () => {
    const html = body(convertToHTML('```\n<div>&amp;</div>\n```'));
    assert.ok(html.includes('&lt;div&gt;'));
  });

  test('auto-closes unclosed code fence on blank line', () => {
    const html = body(convertToHTML('```\nconst x = 1;\n\nMore text.'));
    assert.ok(html.includes('</blockquote>'));
    assert.ok(html.includes('<p>More text.</p>'));
  });

  test('preserves inline markdown inside list items', () => {
    const html = body(convertToHTML('- **bold** item\n- `code` item'));
    assert.equal(
      html,
      '<ul>\n<li><strong>bold</strong> item</li>\n<li><code>code</code> item</li>\n</ul>'
    );
  });

  test('preserves identifiers with underscores inside list items', () => {
    const html = body(
      convertToHTML('- The source_url field\n- The document_url field')
    );
    assert.ok(html.includes('source_url'));
    assert.ok(html.includes('document_url'));
    assert.ok(!html.includes('<em>'), 'should not italicize identifiers');
  });

  test('end-to-end example (greeting + lists + bold + identifiers)', () => {
    const input = `Hi Susie,

Quick clarification before we ship.

**What we've built:**

- \`?source_url=...\` pre-fills a **Source URL** text field.
- The form also has an optional file upload.

1. First option
2. Second option

Thanks,
Nick`;
    const html = body(convertToHTML(input));
    assert.ok(html.includes('<p>Hi Susie,</p>'));
    assert.ok(!html.includes('<strong>Hi Susie,</strong>'));
    assert.ok(html.includes('<p>Thanks,</p>'));
    assert.ok(!html.includes('<strong>Thanks,</strong>'));
    assert.ok(html.includes('<p>Nick</p>'));
    assert.ok(html.includes('<strong>What we&apos;ve built:</strong>') || html.includes("<strong>What we've built:</strong>"));
    assert.ok(html.includes('<code>?source_url=...</code>'));
    assert.ok(!html.includes('<ol'), 'numbered list should be normalized to <ul>');
    const ulCount = (html.match(/<ul>/g) || []).length;
    assert.equal(ulCount, 2, 'should produce exactly two <ul> blocks');
  });

  test('returns valid wrapped HTML', () => {
    const html = convertToHTML('Hello.');
    assert.ok(html.startsWith('<html><head><meta charset="UTF-8"></head>'));
    assert.ok(html.endsWith('</body></html>'));
  });
});

describe('cleanRTF', () => {
  test('removes a simple font table', () => {
    const rtf = '{\\rtf1\\ansi{\\fonttbl\\f0\\froman\\fcharset0 Times-Roman;}\\f0 hi}';
    const out = cleanRTF(rtf);
    assert.ok(!out.includes('\\fonttbl'));
    assert.ok(!out.includes('Times-Roman'));
  });

  test('removes the color table', () => {
    const rtf = '{\\rtf1{\\colortbl;\\red0\\green0\\blue0;}hello}';
    const out = cleanRTF(rtf);
    assert.ok(!out.includes('\\colortbl'));
    assert.ok(!out.includes('\\red0'));
  });

  test('removes the expanded color table', () => {
    const rtf = '{\\rtf1{\\*\\expandedcolortbl;;}hello}';
    const out = cleanRTF(rtf);
    assert.ok(!out.includes('expandedcolortbl'));
  });

  test('handles nested braces inside the font table', () => {
    const rtf = '{\\rtf1{\\fonttbl{\\f0\\fcharset0 Helvetica;}{\\f1\\fcharset0 Bold;}}body}';
    const out = cleanRTF(rtf);
    assert.ok(!out.includes('\\fonttbl'));
    assert.ok(!out.includes('Helvetica'));
    assert.ok(out.includes('body'));
  });

  test('strips \\f<N> font references', () => {
    const rtf = 'before\\f0 after\\f12 more';
    const out = cleanRTF(rtf);
    assert.ok(!out.match(/\\f\d/));
  });

  test('strips \\fs<N> font-size references', () => {
    const rtf = 'before\\fs24 after\\fs36 more';
    const out = cleanRTF(rtf);
    assert.ok(!out.match(/\\fs\d/));
  });

  test('strips \\cf<N> color references', () => {
    const rtf = 'before\\cf0 after\\cf2 more';
    const out = cleanRTF(rtf);
    assert.ok(!out.match(/\\cf\d/));
  });

  test('strips \\cb<N> background-color references', () => {
    const rtf = 'before\\cb1 after\\cb0 more';
    const out = cleanRTF(rtf);
    assert.ok(!out.match(/\\cb\d/));
  });

  test('preserves bold (\\b) and italic (\\i) directives', () => {
    const rtf = '{\\rtf1\\b bold text\\b0 normal \\i italic\\i0}';
    const out = cleanRTF(rtf);
    assert.ok(out.includes('\\b'));
    assert.ok(out.includes('\\i'));
  });

  test('preserves paragraph and list structure', () => {
    const rtf = '\\pard\\par {\\listtext bullet}\\par';
    const out = cleanRTF(rtf);
    assert.ok(out.includes('\\pard'));
    assert.ok(out.includes('\\par'));
    assert.ok(out.includes('listtext'));
  });

  test('is idempotent on input without tables or references', () => {
    const rtf = '{\\rtf1\\b hi\\b0}';
    assert.equal(cleanRTF(rtf), rtf);
  });
});
