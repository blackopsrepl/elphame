class Post < ApplicationRecord
  belongs_to :discussion
  belongs_to :user, optional: true
  belongs_to :quoted_post, class_name: "Post", optional: true
  has_many :quotes, class_name: "Post", foreign_key: "quoted_post_id", dependent: :nullify
  has_many :star_ratings, dependent: :destroy
  has_one_attached :image

  validates :content, presence: true, length: { maximum: 2000 }
  validate :soft_username_not_taken

  after_create :touch_discussion_activity
  after_create :increment_discussion_reply_count
  after_destroy :decrement_discussion_reply_count
  after_destroy :update_discussion_star_cache

  # Star rating methods
  def update_star_cache!
    update_columns(
      star_total_cache: star_ratings.sum(:rating),
      star_count_cache: star_ratings.count
    )
  end

  def average_stars
    return 0.0 if star_count_cache.zero?
    (star_total_cache / star_count_cache.to_f).round(1)
  end

  def star_rating_for(user)
    return nil unless user
    star_ratings.find_by(user: user)&.rating
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
    # Check direct user association first
    return user.avatar.attached? if user.present?

    # Fallback: lookup user by author_name for legacy posts
    if author_name.present?
      fallback_user = find_user_by_author_name
      return fallback_user&.avatar&.attached? || false
    end

    false
  end

  def avatar
    return unless has_avatar?

    # Get user from association or fallback lookup
    avatar_user = user || find_user_by_author_name
    return unless avatar_user&.avatar&.attached?

    # Return thumbnail variant to prevent huge images
    avatar_user.avatar_thumbnail
  end

  private

  def find_user_by_author_name
    return nil unless author_name.present?

    # Try exact match first
    found_user = User.find_by("LOWER(username) = ?", author_name.downcase)
    return found_user if found_user

    # Try without spaces (e.g., "King Terry" -> "KingTerry")
    normalized_name = author_name.gsub(/\s+/, "")
    User.find_by("LOWER(username) = ?", normalized_name.downcase)
  end

  def soft_username_not_taken
    if soft_username.present? && !User.soft_username_available?(soft_username)
      errors.add(:soft_username, "is already taken by a registered user")
    end
  end

  def touch_discussion_activity
    discussion.touch_activity!
  end

  def increment_discussion_reply_count
    return if self == discussion.posts.order(:created_at).first
    discussion.increment!(:reply_count_cache)
  end

  def decrement_discussion_reply_count
    return if discussion.reply_count_cache <= 0
    discussion.decrement!(:reply_count_cache)
  end

  def update_discussion_star_cache
    discussion.update_total_stars! if star_total_cache > 0
  end
end
