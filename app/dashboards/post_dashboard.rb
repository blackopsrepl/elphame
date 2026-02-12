require "administrate/base_dashboard"

class PostDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    content: Field::Text,
    discussion: Field::BelongsTo,
    user: Field::BelongsTo.with_options(optional: true),
    quoted_post: Field::BelongsTo.with_options(
      class_name: "Post",
      optional: true
    ),
    star_ratings: Field::HasMany,
    star_total_cache: Field::Number.with_options(decimals: 1),
    star_count_cache: Field::Number,
    author_name: Field::String,
    soft_username: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    content
    discussion
    star_total_cache
    star_count_cache
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    content
    discussion
    user
    author_name
    soft_username
    quoted_post
    star_ratings
    star_total_cache
    star_count_cache
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    content
    discussion
  ].freeze

  COLLECTION_SEARCH_FIELDS = %i[
    content
    author_name
    soft_username
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(post)
    "Post ##{post.id}"
  end
end
