require "administrate/base_dashboard"

class DiscussionDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    subject: Field::String,
    content: Field::Text,
    realm: Field::BelongsTo,
    user: Field::BelongsTo.with_options(optional: true),
    posts: Field::HasMany,
    labels: Field::HasMany,
    total_stars: Field::Number.with_options(decimals: 1),
    reply_count_cache: Field::Number,
    pinned: Field::Boolean,
    pinned_at: Field::DateTime,
    manual_boost_score: Field::Number,
    last_activity_at: Field::DateTime,
    author_name: Field::String,
    soft_username: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    subject
    realm
    reply_count_cache
    total_stars
    pinned
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    subject
    content
    realm
    user
    author_name
    soft_username
    posts
    labels
    total_stars
    reply_count_cache
    pinned
    pinned_at
    manual_boost_score
    last_activity_at
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    subject
    content
    realm
    manual_boost_score
  ].freeze

  COLLECTION_SEARCH_FIELDS = %i[
    subject
    content
    author_name
    soft_username
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(discussion)
    discussion.subject.presence || "(untitled ##{discussion.id})"
  end
end
