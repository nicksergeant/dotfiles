"""Tests for md2richtext.py — ports scripts/md2richtext.test.js.

Run with:
  python3 -m unittest scripts/test_md2richtext.py
  python3 scripts/test_md2richtext.py
"""

from __future__ import annotations

import os
import re
import sys
import unittest

# Allow running from any cwd by adding this file's dir to sys.path.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from md2richtext import (  # noqa: E402
    clean_rtf,
    convert_to_html,
    escape_html,
    process_inline_formatting,
)


def _body(html: str) -> str:
    """Strip the boilerplate <html><head>...<body ...> wrapper so individual
    tests can focus on meaningful structure."""
    html = re.sub(
        r'^<html><head><meta charset="UTF-8"></head>'
        r'<body style="background-color: white;">\n',
        "",
        html,
    )
    html = re.sub(r"</body></html>$", "", html)
    return html.strip()


class EscapeHTMLTests(unittest.TestCase):
    def test_escapes_ampersand(self):
        self.assertEqual(escape_html("a & b"), "a &amp; b")

    def test_escapes_angle_brackets(self):
        self.assertEqual(escape_html("<div>"), "&lt;div&gt;")

    def test_escapes_double_quotes(self):
        self.assertEqual(escape_html('say "hi"'), "say &quot;hi&quot;")

    def test_escapes_ampersand_before_other_entities_no_double_encoding(self):
        # Ampersand is escaped first, so subsequent <, > escapes don't
        # produce &amp;lt;, etc. (matches JS behavior).
        self.assertEqual(escape_html("<a>&</a>"), "&lt;a&gt;&amp;&lt;/a&gt;")

    def test_passes_plain_text_unchanged(self):
        self.assertEqual(escape_html("hello world"), "hello world")


class ProcessInlineFormattingTests(unittest.TestCase):
    def test_wraps_bold_double_asterisk(self):
        self.assertEqual(
            process_inline_formatting("**bold**"), "<strong>bold</strong>"
        )

    def test_wraps_bold_double_underscore(self):
        self.assertEqual(
            process_inline_formatting("__bold__"), "<strong>bold</strong>"
        )

    def test_wraps_italic_single_asterisk(self):
        self.assertEqual(process_inline_formatting("*italic*"), "<em>italic</em>")

    def test_wraps_italic_standalone_underscore(self):
        self.assertEqual(process_inline_formatting("_italic_"), "<em>italic</em>")

    def test_does_not_italicize_intra_word_underscore(self):
        self.assertEqual(process_inline_formatting("source_url"), "source_url")

    def test_does_not_italicize_intra_word_underscore_in_sentence(self):
        self.assertEqual(
            process_inline_formatting("the source_url field"),
            "the source_url field",
        )

    def test_preserves_identifiers_with_multiple_underscores(self):
        self.assertEqual(
            process_inline_formatting("Use document_url_field here"),
            "Use document_url_field here",
        )

    def test_wraps_inline_code(self):
        self.assertEqual(process_inline_formatting("`foo`"), "<code>foo</code>")

    def test_escapes_html_entities_in_inline_code(self):
        self.assertEqual(
            process_inline_formatting("`<div>`"), "<code>&lt;div&gt;</code>"
        )

    def test_preserves_underscores_in_inline_code(self):
        self.assertEqual(
            process_inline_formatting("`source_url`"),
            "<code>source_url</code>",
        )

    def test_renders_link(self):
        self.assertEqual(
            process_inline_formatting("[link](https://example.com)"),
            '<a href="https://example.com">link</a>',
        )

    def test_handles_mixed_inline_formatting(self):
        self.assertEqual(
            process_inline_formatting("Use **`source_url`** for the API"),
            "Use <strong><code>source_url</code></strong> for the API",
        )

    def test_escapes_bare_ampersand_but_not_existing_entities(self):
        self.assertEqual(process_inline_formatting("a & b"), "a &amp; b")
        self.assertEqual(process_inline_formatting("a &amp; b"), "a &amp; b")
        self.assertEqual(process_inline_formatting("a &#123; b"), "a &#123; b")


class ConvertToHTMLTests(unittest.TestCase):
    def test_wraps_single_paragraph(self):
        self.assertEqual(_body(convert_to_html("Hello world.")), "<p>Hello world.</p>")

    def test_separates_paragraphs_without_empty_p(self):
        html = _body(convert_to_html("First paragraph.\n\nSecond paragraph."))
        self.assertEqual(html, "<p>First paragraph.</p>\n<p>Second paragraph.</p>")
        self.assertNotIn("<p></p>", html)

    def test_collapses_multiple_blank_lines(self):
        html = _body(convert_to_html("First paragraph.\n\n\n\nSecond paragraph."))
        self.assertNotIn("<p></p>", html)

    def test_converts_unordered_lists(self):
        html = _body(convert_to_html("- one\n- two\n- three"))
        self.assertEqual(
            html, "<ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>"
        )

    def test_converts_numbered_lists_to_bulleted(self):
        html = _body(convert_to_html("1. one\n2. two\n3. three"))
        self.assertEqual(
            html, "<ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>"
        )
        self.assertNotIn("<ol", html)

    def test_mixed_numbered_and_bulleted_collapse_to_single_ul(self):
        html = _body(convert_to_html("1. numbered\n- bulleted\n2. numbered"))
        self.assertEqual(
            html,
            "<ul>\n<li>numbered</li>\n<li>bulleted</li>\n<li>numbered</li>\n</ul>",
        )

    def test_closes_list_when_followed_by_paragraph(self):
        html = _body(convert_to_html("- item\n\nParagraph after list."))
        self.assertEqual(
            html, "<ul>\n<li>item</li>\n</ul>\n<p>Paragraph after list.</p>"
        )

    def test_explicit_h1_becomes_bold_paragraph(self):
        self.assertEqual(
            _body(convert_to_html("# My Heading")),
            "<p><strong>My Heading</strong></p>",
        )

    def test_explicit_h2_becomes_bold_paragraph(self):
        self.assertEqual(
            _body(convert_to_html("## Subheading")),
            "<p><strong>Subheading</strong></p>",
        )

    def test_bolds_implicit_header(self):
        html = _body(
            convert_to_html(
                "Intro paragraph.\n\nSection Heading\n\nNext paragraph."
            )
        )
        self.assertIn("<p><strong>Section Heading</strong></p>", html)

    def test_does_not_bold_greeting_ending_in_comma(self):
        html = _body(convert_to_html("Hi Susie,\n\nNext paragraph."))
        self.assertIn("<p>Hi Susie,</p>", html)
        self.assertNotIn("<strong>Hi Susie,</strong>", html)

    def test_does_not_bold_closing_ending_in_comma(self):
        html = _body(convert_to_html("Some text.\n\nThanks,\n\nNick"))
        self.assertIn("<p>Thanks,</p>", html)
        self.assertNotIn("<strong>Thanks,</strong>", html)

    def test_does_not_bold_lines_ending_in_terminator(self):
        for fragment in ("A short period sentence.", "What about this?", "Wow!"):
            html = _body(convert_to_html(f"Intro.\n\n{fragment}\n\nNext."))
            self.assertNotIn(
                f"<strong>{fragment}", html, msg=f"unexpected bold for: {fragment}"
            )

    def test_still_bolds_line_ending_with_colon(self):
        html = _body(
            convert_to_html("Intro paragraph.\n\nWhat we built:\n\n- one\n- two")
        )
        self.assertIn("<p><strong>What we built:</strong></p>", html)

    def test_skips_horizontal_rules(self):
        html = _body(convert_to_html("Before.\n\n---\n\nAfter."))
        self.assertEqual(html, "<p>Before.</p>\n<p>After.</p>")

    def test_renders_fenced_code_as_blockquote(self):
        html = _body(convert_to_html("```\nconst x = 1;\nconst y = 2;\n```"))
        self.assertEqual(
            html,
            "<blockquote>\n<p>const x = 1;</p>\n<p>const y = 2;</p>\n</blockquote>",
        )

    def test_escapes_html_inside_fenced_code(self):
        html = _body(convert_to_html("```\n<div>&amp;</div>\n```"))
        self.assertIn("&lt;div&gt;", html)

    def test_auto_closes_unclosed_code_fence_on_blank_line(self):
        html = _body(convert_to_html("```\nconst x = 1;\n\nMore text."))
        self.assertIn("</blockquote>", html)
        self.assertIn("<p>More text.</p>", html)

    def test_preserves_inline_markdown_inside_list_items(self):
        html = _body(convert_to_html("- **bold** item\n- `code` item"))
        self.assertEqual(
            html,
            "<ul>\n<li><strong>bold</strong> item</li>\n<li><code>code</code> item</li>\n</ul>",
        )

    def test_preserves_identifiers_with_underscores_in_list_items(self):
        html = _body(
            convert_to_html("- The source_url field\n- The document_url field")
        )
        self.assertIn("source_url", html)
        self.assertIn("document_url", html)
        self.assertNotIn("<em>", html)

    def test_end_to_end_example(self):
        markdown = (
            "Hi Susie,\n"
            "\n"
            "Quick clarification before we ship.\n"
            "\n"
            "**What we've built:**\n"
            "\n"
            "- `?source_url=...` pre-fills a **Source URL** text field.\n"
            "- The form also has an optional file upload.\n"
            "\n"
            "1. First option\n"
            "2. Second option\n"
            "\n"
            "Thanks,\n"
            "Nick"
        )
        html = _body(convert_to_html(markdown))
        self.assertIn("<p>Hi Susie,</p>", html)
        self.assertNotIn("<strong>Hi Susie,</strong>", html)
        self.assertIn("<p>Thanks,</p>", html)
        self.assertNotIn("<strong>Thanks,</strong>", html)
        self.assertIn("<p>Nick</p>", html)
        # The apostrophe may be emitted literally or as an entity depending on
        # how the renderer treats it; either is fine.
        self.assertTrue(
            "<strong>What we've built:</strong>" in html
            or "<strong>What we&apos;ve built:</strong>" in html,
            f"expected bolded section heading, got: {html}",
        )
        self.assertIn("<code>?source_url=...</code>", html)
        self.assertNotIn("<ol", html)
        self.assertEqual(len(re.findall(r"<ul>", html)), 2)

    def test_returns_valid_wrapped_html(self):
        html = convert_to_html("Hello.")
        self.assertTrue(html.startswith('<html><head><meta charset="UTF-8"></head>'))
        self.assertTrue(html.endswith("</body></html>"))


class CleanRTFTests(unittest.TestCase):
    def test_removes_simple_font_table(self):
        rtf = "{\\rtf1\\ansi{\\fonttbl\\f0\\froman\\fcharset0 Times-Roman;}\\f0 hi}"
        out = clean_rtf(rtf)
        self.assertNotIn("\\fonttbl", out)
        self.assertNotIn("Times-Roman", out)

    def test_removes_color_table(self):
        rtf = "{\\rtf1{\\colortbl;\\red0\\green0\\blue0;}hello}"
        out = clean_rtf(rtf)
        self.assertNotIn("\\colortbl", out)
        self.assertNotIn("\\red0", out)

    def test_removes_expanded_color_table(self):
        rtf = "{\\rtf1{\\*\\expandedcolortbl;;}hello}"
        out = clean_rtf(rtf)
        self.assertNotIn("expandedcolortbl", out)

    def test_handles_nested_braces_in_font_table(self):
        rtf = (
            "{\\rtf1{\\fonttbl{\\f0\\fcharset0 Helvetica;}"
            "{\\f1\\fcharset0 Bold;}}body}"
        )
        out = clean_rtf(rtf)
        self.assertNotIn("\\fonttbl", out)
        self.assertNotIn("Helvetica", out)
        self.assertIn("body", out)

    def test_strips_font_references(self):
        rtf = "before\\f0 after\\f12 more"
        out = clean_rtf(rtf)
        self.assertIsNone(re.search(r"\\f\d", out))

    def test_strips_font_size_references(self):
        rtf = "before\\fs24 after\\fs36 more"
        out = clean_rtf(rtf)
        self.assertIsNone(re.search(r"\\fs\d", out))

    def test_strips_color_references(self):
        rtf = "before\\cf0 after\\cf2 more"
        out = clean_rtf(rtf)
        self.assertIsNone(re.search(r"\\cf\d", out))

    def test_strips_background_color_references(self):
        rtf = "before\\cb1 after\\cb0 more"
        out = clean_rtf(rtf)
        self.assertIsNone(re.search(r"\\cb\d", out))

    def test_preserves_bold_and_italic_directives(self):
        rtf = "{\\rtf1\\b bold text\\b0 normal \\i italic\\i0}"
        out = clean_rtf(rtf)
        self.assertIn("\\b", out)
        self.assertIn("\\i", out)

    def test_preserves_paragraph_and_list_structure(self):
        rtf = "\\pard\\par {\\listtext bullet}\\par"
        out = clean_rtf(rtf)
        self.assertIn("\\pard", out)
        self.assertIn("\\par", out)
        self.assertIn("listtext", out)

    def test_idempotent_without_tables_or_refs(self):
        rtf = "{\\rtf1\\b hi\\b0}"
        self.assertEqual(clean_rtf(rtf), rtf)


if __name__ == "__main__":
    unittest.main()
