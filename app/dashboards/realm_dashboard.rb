require "administrate/base_dashboard"

class RealmDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    name: Field::String,
    slug: Field::String,
    description: Field::Text,
    icon: Field::String,
    color: Field::String,
    rules: Field::Text,
    position: Field::Number,
    discussions_count: Field::Number,
    discussions: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    icon
    name
    slug
    discussions_count
    position
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    name
    slug
    icon
    color
    description
    rules
    position
    discussions_count
    discussions
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    name
    slug
    icon
    color
    description
    rules
    position
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(realm)
    "#{realm.icon} /#{realm.slug}/"
  end
end
