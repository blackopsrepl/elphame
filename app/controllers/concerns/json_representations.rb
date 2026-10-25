# The JSON shapes the agent API returns, kept in one place so every endpoint
# that emits a discussion, a post, or a rating emits the same fields.
module JsonRepresentations
  extend ActiveSupport::Concern

  private

  def realm_json(realm)
    { id: realm.id, name: realm.name, slug: realm.slug }
  end

  def discussion_json(discussion)
    {
      id: discussion.id,
      subject: discussion.subject,
      content: discussion.content,
      realm: realm_json(discussion.realm),
      author: discussion.display_name,
      pinned: discussion.pinned,
      manual_boost_score: discussion.manual_boost_score,
      reply_count: discussion.reply_count_cache,
      total_stars: discussion.total_stars.to_f,
      labels: discussion.labels.map { |label| { name: label.name, category: label.category } },
      image_url: attachment_url(discussion.image),
      last_activity_at: discussion.last_activity_at,
      created_at: discussion.created_at
    }
  end

  def post_json(post)
    {
      id: post.id,
      discussion_id: post.discussion_id,
      content: post.content,
      author: post.display_name,
      quoted_post_id: post.quoted_post_id,
      image_url: attachment_url(post.image),
      stars: star_summary_json(post),
      created_at: post.created_at,
      updated_at: post.updated_at
    }
  end

  def discussions_listing_json(realm, discussions)
    {
      realm: realm_json(realm).merge(description: realm.description),
      discussions: discussions.map { |d| discussion_json(d) },
      meta: page_meta_json(discussions)
    }
  end

  def star_summary_json(post)
    {
      average: post.average_stars.to_f,
      count: post.star_count_cache,
      total: post.star_total_cache.to_f
    }
  end

  def attachment_url(attachment)
    attachment.attached? ? url_for(attachment) : nil
  end

  def page_meta_json(relation)
    {
      page: relation.current_page,
      per_page: relation.limit_value,
      total_pages: relation.total_pages,
      total_count: relation.total_count
    }
  end
end
