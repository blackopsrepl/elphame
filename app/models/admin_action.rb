class AdminAction < ApplicationRecord
  belongs_to :admin_user, class_name: "User"

  validates :action_type, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(action_type: type) }

  # Convenience factory method for logging admin actions
  def self.log!(admin_user:, action_type:, target: nil, details: nil)
    create!(
      admin_user: admin_user,
      action_type: action_type,
      target_type: target&.class&.name,
      target_id: target&.id,
      details: details
    )
  end

  def target
    return nil unless target_type.present? && target_id.present?
    target_type.constantize.find_by(id: target_id)
  end

  def description
    case action_type
    when "user_destroy"
      "Deleted user: #{details}"
    when "discussion_destroy"
      "Deleted discussion: #{details}"
    when "post_destroy"
      "Deleted post: #{details}"
    when "discussion_pin"
      "Pinned discussion: #{details}"
    when "discussion_unpin"
      "Unpinned discussion: #{details}"
    when "discussion_boost"
      "Boosted discussion: #{details}"
    when "label_add"
      "Added label: #{details}"
    when "label_remove"
      "Removed label: #{details}"
    when "realm_create"
      "Created realm: #{details}"
    when "realm_update"
      "Updated realm: #{details}"
    when "realm_destroy"
      "Deleted realm: #{details}"
    when "user_create"
      "Created user: #{details}"
    when "user_update"
      "Updated user: #{details}"
    when "discussion_create"
      "Created discussion: #{details}"
    when "discussion_update"
      "Updated discussion: #{details}"
    when "label_create"
      "Created label: #{details}"
    when "label_update"
      "Updated label: #{details}"
    when "label_destroy"
      "Deleted label: #{details}"
    else
      "#{action_type}: #{details}"
    end
  end
end
