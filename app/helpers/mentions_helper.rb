module MentionsHelper
  def highlight_mentions(text)
    return "" if text.blank?
    escaped = h(text)
    escaped.gsub(/\B@([A-Za-z][A-Za-z0-9_-]*)/) do |match|
      name = $1
      agent = MentionParser.resolve_agent(name)
      if agent
        "<span class=\"mention-agent\">#{match}</span>"
      else
        match
      end
    end.html_safe
  end
end
