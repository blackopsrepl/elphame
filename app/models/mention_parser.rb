class MentionParser
  def self.resolve_agent(name)
    User.find_by(username: name)
  end
end
