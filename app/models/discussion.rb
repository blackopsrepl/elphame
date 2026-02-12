class Discussion < ApplicationRecord
  include ActivityScoring

  belongs_to :realm, counter_cache: true
  belongs_to :user, optional: true
  has_many :posts, dependent: :destroy
  has_many :thread_labels, dependent: :destroy
  has_many :labels, through: :thread_labels

  belongs_to :pinned_by_user, class_name: "User", optional: true
  has_one_attached :image

  validates :content, presence: true, length: { maximum: 5000 }
  validates :subject, length: { maximum: 200 }
  validate :soft_username_not_taken

  # Callbacks
  after_create :set_initial_activity
  after_create :create_first_post
  before_save :update_activity_timestamp, if: :content_changed?

  # Scopes
  scope :pinned, -> { where(pinned: true).order(pinned_at: :desc) }
  scope :unpinned, -> { where(pinned: false) }
  scope :with_label, ->(label_name) { joins(:labels).where(labels: { name: label_name }) }

  # by_activity_score is provided by ActivityScoring concern

  scope :by_recent_activity, -> { order(last_activity_at: :desc, created_at: :desc) }
  scope :by_newest, -> { order(created_at: :desc) }
  scope :by_most_replies, -> { order(reply_count_cache: :desc) }
  scope :by_stars, -> { order(total_stars: :desc) }
  scope :by_stars_asc, -> { order(total_stars: :asc) }

  # Star rating aggregation
  def update_total_stars!
    update_column(:total_stars, posts.sum(:star_total_cache))
  end

  def total_star_ratings_count
    posts.sum(:star_count_cache)
  end

  # Weighted average across all posts (0.0..5.0)
  def average_stars
    count = total_star_ratings_count
    return 0.0 if count.zero?
    (total_stars / count.to_f).round(1)
  end

  def display_name
    if user.present?
      user.username
    elsif soft_username.present?
      soft_username
    elsif author_name.present?
      author_name
    else
      "Anonymous"
    end
  end

  def has_avatar?
    return user.avatar.attached? if user.present?

    if author_name.present?
      fallback_user = find_user_by_author_name
      return fallback_user&.avatar&.attached? || false
    end

    false
  end

  def avatar
    return unless has_avatar?

    avatar_user = user || find_user_by_author_name
    return unless avatar_user&.avatar&.attached?

    avatar_user.avatar_thumbnail
  end

  # Thread type label (user-selectable, from the unified label system)
  def thread_type_label
    labels.find_by(category: "type")
  end

  def thread_type_name
    thread_type_label&.display_name || "💬 General"
  end

  # Set the thread type (replaces old tag= functionality)
  def set_thread_type(label_name, user: nil)
    # Remove any existing type labels first
    thread_labels.joins(:label).where(labels: { category: "type" }).destroy_all
    # Add the new one
    add_label(label_name, user: user) if label_name.present?
  end

  # Labeling methods
  def add_label(label_name, user: nil)
    label = Label.find_by(name: label_name)
    return false unless label

    thread_labels.find_or_create_by(label: label) do |tl|
      tl.applied_by_user = user
      tl.applied_at = Time.current
    end
  end

  def remove_label(label_name)
    label = Label.find_by(name: label_name)
    return false unless label

    thread_labels.where(label: label).destroy_all
  end

  def has_label?(label_name)
    labels.exists?(name: label_name)
  end

  # Pinning
  def pin!(user)
    update(
      pinned: true,
      pinned_at: Time.current,
      pinned_by_user: user
    )
  end

  def unpin!
    update(
      pinned: false,
      pinned_at: nil,
      pinned_by_user_id: nil
    )
  end

  # Cache management
  def update_reply_count_cache
    update_column(:reply_count_cache, [ posts.count - 1, 0 ].max)
  end

  def touch_activity!
    update_column(:last_activity_at, Time.current)
  end

  private

  def set_initial_activity
    update_column(:last_activity_at, created_at)
  end

  def create_first_post
    return if content.blank?
    return if posts.any?

    posts.create!(
      content: content,
      user: user,
      author_name: author_name,
      soft_username: soft_username,
      created_at: created_at,
      updated_at: updated_at
    )
  end

  def update_activity_timestamp
    self.last_activity_at = Time.current
  end

  def find_user_by_author_name
    return nil unless author_name.present?

    found_user = User.find_by("LOWER(username) = ?", author_name.downcase)
    return found_user if found_user

    normalized_name = author_name.gsub(/\s+/, "")
    User.find_by("LOWER(username) = ?", normalized_name.downcase)
  end

  def soft_username_not_taken
    if soft_username.present? && !User.soft_username_available?(soft_username)
      errors.add(:soft_username, "is already taken by a registered user")
    end
  end
end
