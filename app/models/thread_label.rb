class ThreadLabel < ApplicationRecord
  belongs_to :discussion
  belongs_to :label
  belongs_to :applied_by_user, class_name: "User", optional: true

  validates :discussion_id, uniqueness: { scope: :label_id }

  before_create :set_applied_at

  private

  def set_applied_at
    self.applied_at ||= Time.current
  end
end
