require "test_helper"

class StarRatingTest < ActiveSupport::TestCase
  test "valid star rating" do
    rating = StarRating.new(post: posts(:one), user: users(:admin_user), rating: 3.5)
    assert rating.valid?
  end

  test "requires rating" do
    rating = StarRating.new(post: posts(:one), user: users(:admin_user))
    assert_not rating.valid?
  end

  test "minimum rating is 0.5" do
    rating = StarRating.new(post: posts(:one), user: users(:admin_user), rating: 0.0)
    assert_not rating.valid?
  end

  test "maximum rating is 5.0" do
    rating = StarRating.new(post: posts(:one), user: users(:admin_user), rating: 5.5)
    assert_not rating.valid?
  end

  test "rating must be half increment" do
    rating = StarRating.new(post: posts(:one), user: users(:admin_user), rating: 2.3)
    assert_not rating.valid?
    assert_includes rating.errors[:rating], "must be a multiple of 0.5 between #{StarRating::MINIMUM_RATING} and #{StarRating::MAXIMUM_RATING}"
  end

  test "valid half increments" do
    [ 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0 ].each do |val|
      rating = StarRating.new(post: posts(:one), user: users(:admin_user), rating: val)
      assert rating.valid?, "Expected #{val} to be valid"
    end
  end

  test "unique per user per post" do
    # star_ratings(:one) already exists for regular_user + posts(:two)
    duplicate = StarRating.new(post: posts(:two), user: users(:regular_user), rating: 4.0)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already rated this post"
  end

  test "VALID_RATINGS excludes 0.0" do
    assert_not_includes StarRating::VALID_RATINGS, 0.0
    assert_includes StarRating::VALID_RATINGS, 0.5
    assert_includes StarRating::VALID_RATINGS, 5.0
  end
end
