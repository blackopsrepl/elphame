class Webhook < ApplicationRecord
  ENDPOINT_TIMEOUT = 7.seconds

  belongs_to :user

  def deliver(post)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = ENDPOINT_TIMEOUT
    http.read_timeout = ENDPOINT_TIMEOUT

    request = Net::HTTP::Post.new(uri.path.presence || "/", "Content-Type" => "application/json")
    request.body = payload(post)

    response = http.request(request)

    if response.code == "200" && response.content_type&.start_with?("text/")
      reply_text = String.new(response.body).force_encoding("UTF-8")
      post.discussion.posts.create!(content: reply_text, user: user) if reply_text.present?
    end
  rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, Errno::ECONNREFUSED
    # Silently fail — webhook delivery is best-effort
  end

  private

  def payload(post)
    {
      user: { id: post.user&.id, name: post.display_name },
      realm: { id: post.discussion.realm.id, name: post.discussion.realm.name, slug: post.discussion.realm.slug },
      discussion: { id: post.discussion.id, subject: post.discussion.subject },
      post: { id: post.id, content: post.content }
    }.to_json
  end
end
