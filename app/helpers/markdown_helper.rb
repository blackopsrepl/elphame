module MarkdownHelper
  MARKDOWN_TAGS = %w[
    p br hr strong em del code pre blockquote ul ol li a
    h1 h2 h3 h4 h5 h6 table thead tbody tr th td
  ].freeze
  MARKDOWN_ATTRIBUTES = %w[href title].freeze

  # Renders a post body as GitHub-flavoured Markdown. Single newlines stay line
  # breaks, as they were when bodies were plain text. Raw HTML in the source is
  # not trusted: the rendered output passes through an allowlist sanitiser, so
  # only the Markdown element set survives.
  def render_markdown(text, html_class: nil)
    return "" if text.blank?

    html = Kramdown::Document.new(
      text,
      input: "GFM",
      hard_wrap: true,
      auto_ids: false,
      syntax_highlighter: nil
    ).to_html

    tag.div(
      sanitize(html, tags: MARKDOWN_TAGS, attributes: MARKDOWN_ATTRIBUTES),
      class: [ "markdown-body", html_class ]
    )
  end
end
