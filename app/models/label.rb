class Label < ApplicationRecord
  has_many :thread_labels, dependent: :destroy
  has_many :discussions, through: :thread_labels

  validates :name, presence: true, uniqueness: true
  validates :category, presence: true, inclusion: { in: %w[priority status type] }

  scope :active, -> { where(active: true) }
  scope :by_category, ->(cat) { where(category: cat).order(:position) }
  scope :user_selectable, -> { where(user_selectable: true) }
  scope :admin_only, -> { where(user_selectable: false) }

  def display_name
    "#{emoji} #{name.humanize}"
  end
end
