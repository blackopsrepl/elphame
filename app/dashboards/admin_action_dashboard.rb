require "administrate/base_dashboard"

class AdminActionDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    admin_user: Field::BelongsTo.with_options(class_name: "User"),
    action_type: Field::String,
    target_type: Field::String,
    target_id: Field::Number,
    details: Field::Text,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    admin_user
    action_type
    details
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    admin_user
    action_type
    target_type
    target_id
    details
    created_at
  ].freeze

  FORM_ATTRIBUTES = [].freeze

  COLLECTION_SEARCH_FIELDS = %i[
    action_type
    details
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(admin_action)
    "Action ##{admin_action.id}"
  end
end
