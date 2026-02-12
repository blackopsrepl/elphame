require "test_helper"

class RatingFlowTest < ActionDispatch::IntegrationTest
  test "full star rating flow" do
    post_record = posts(:one)

    # Verify initial state
    assert_equal 0, post_record.star_count_cache
    assert_equal 0.0, post_record.star_total_cache

    # Sign in and rate
    sign_in_regular_user
    post post_star_rating_url(post_record), params: { rating: 4.5 }, as: :turbo_stream
    assert_response :success

    # Verify caches updated
    post_record.reload
    assert_equal 1, post_record.star_count_cache
    assert_equal 4.5, post_record.star_total_cache.to_f
    assert_equal 4.5, post_record.average_stars

    # Verify discussion total_stars updated
    discussion = post_record.discussion
    discussion.reload
    assert discussion.total_stars >= 4.5
  end

  test "anonymous users cannot rate" do
    assert_no_difference("StarRating.count") do
      post post_star_rating_url(posts(:one)), params: { rating: 3.0 }
    end
    assert_response :redirect
  end

  test "pin and boost require admin" do
    sign_in_regular_user
    discussion = discussions(:one)

    post pin_discussion_url(discussion)
    assert_response :redirect
    assert_not discussion.reload.pinned?

    post boost_discussion_url(discussion)
    assert_response :redirect
  end

  test "admin can pin discussion" do
    sign_in_admin
    discussion = discussions(:one)

    post pin_discussion_url(discussion)
    assert_response :redirect
    assert discussion.reload.pinned?
  end

  test "admin can boost discussion" do
    sign_in_admin
    discussion = discussions(:one)
    original_score = discussion.manual_boost_score

    post boost_discussion_url(discussion), params: { amount: 25 }
    assert_response :redirect
    assert_equal original_score + 25, discussion.reload.manual_boost_score
  end
end
