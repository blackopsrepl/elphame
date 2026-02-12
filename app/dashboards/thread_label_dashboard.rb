require "administrate/base_dashboard"

class ThreadLabelDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    discussion: Field::BelongsTo,
    label: Field::BelongsTo,
    applied_by_user: Field::BelongsTo.with_options(
      class_name: "User",
      optional: true
    ),
    applied_at: Field::DateTime,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    discussion
    label
    applied_by_user
    applied_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    discussion
    label
    applied_by_user
    applied_at
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    discussion
    label
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(thread_label)
    "#{thread_label.label&.name} on Discussion ##{thread_label.discussion_id}"
  end
end
