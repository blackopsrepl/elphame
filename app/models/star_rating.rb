class StarRating < ApplicationRecord
  MINIMUM_RATING = 0.5
  MAXIMUM_RATING = 5.0
  VALID_RATINGS = (1..10).map { |i| i * 0.5 }.freeze  # 0.5, 1.0, 1.5, ..., 5.0

  # Rate limiting: minimum seconds between rating changes per user
  RATE_LIMIT_SECONDS = 5

  belongs_to :post
  belongs_to :user

  validates :rating, presence: true,
                     numericality: {
                       greater_than_or_equal_to: MINIMUM_RATING,
                       less_than_or_equal_to: MAXIMUM_RATING
                     }
  validates :user_id, uniqueness: { scope: :post_id, message: "has already rated this post" }
  validate :rating_is_half_increment
  validate :rate_limit_not_exceeded, on: :update

  after_commit :update_caches, on: [ :create, :update, :destroy ]

  private

  def rating_is_half_increment
    return if rating.nil?
    unless VALID_RATINGS.include?(rating.to_f)
      errors.add(:rating, "must be a multiple of 0.5 between #{MINIMUM_RATING} and #{MAXIMUM_RATING}")
    end
  end

  def rate_limit_not_exceeded
    return unless updated_at_was.present?
    elapsed = Time.current - updated_at_was
    if elapsed < RATE_LIMIT_SECONDS
      errors.add(:base, "Please wait #{RATE_LIMIT_SECONDS} seconds between rating changes")
    end
  end

  def update_caches
    post_record = Post.find_by(id: post_id)
    return unless post_record

    post_record.update_star_cache!
    post_record.discussion&.update_total_stars!
  end
end
