require "administrate/base_dashboard"

class StarRatingDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    rating: Field::Number.with_options(decimals: 1),
    post: Field::BelongsTo,
    user: Field::BelongsTo,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    rating
    post
    user
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    rating
    post
    user
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    rating
    post
    user
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(star_rating)
    "Rating ##{star_rating.id} (#{star_rating.rating})"
  end
end
