require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    username: Field::String,
    email: Field::Email,
    password: Field::Password,
    password_confirmation: Field::Password,
    admin: Field::Boolean,
    discussions: Field::HasMany,
    posts: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    username
    email
    admin
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = %i[
    id
    username
    email
    admin
    discussions
    posts
    created_at
    updated_at
  ].freeze

  FORM_ATTRIBUTES = %i[
    username
    email
    password
    password_confirmation
    admin
  ].freeze

  COLLECTION_SEARCH_FIELDS = %i[
    username
    email
  ].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(user)
    user.username
  end
end
