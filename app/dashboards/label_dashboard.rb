require "administrate/base_dashboard"

class LabelDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    name: Field::String,
    category: Field::Select.with_options(collection: %w[priority status type]),
    emoji: Field::String,
    sort_weight: Field::Number,
    position: Field::Number,
    active: Field::Boolean,
    user_selectable: Field::Boolean,
    thread_labels: Field::HasMany,
    discussions: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    emoji
    name
    category
    sort_weight
    user_selectable
    active
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    name
    category
    emoji
    sort_weight
    position
    active
    user_selectable
    discussions
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    name
    category
    emoji
    sort_weight
    position
    active
    user_selectable
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(label)
    "#{label.emoji} #{label.name}"
  end
end
