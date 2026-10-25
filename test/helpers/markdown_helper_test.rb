require "test_helper"

class MarkdownHelperTest < ActionView::TestCase
  test "renders GitHub-flavoured Markdown" do
    html = render_markdown("**bold** and ~~gone~~\n\n- one\n- two")

    assert_includes html, "<strong>bold</strong>"
    assert_includes html, "<del>gone</del>"
    assert_includes html, "<li>one</li>"
  end

  test "keeps single newlines as line breaks" do
    assert_includes render_markdown("first\nsecond"), "first<br>"
  end

  test "renders nothing for a blank body" do
    assert_equal "", render_markdown("  ")
  end

  {
    "a script tag" => "<script>alert(1)</script>",
    "an event handler" => "<b onclick=\"alert(1)\">x</b>",
    "a javascript: link" => "[x](javascript:alert(1))",
    "an inline style" => "<p style=\"position:fixed\">x</p>",
    "kramdown's raw-HTML extension" => "{::nomarkdown}<b onclick=1>x</b>{:/}",
    "a kramdown attribute list" => "para\n{: onclick=\"alert(1)\"}"
  }.each do |name, source|
    test "strips #{name}" do
      html = render_markdown(source)

      assert_no_match(/<script|onclick|onerror|javascript:|style=/i, html)
    end
  end
end
