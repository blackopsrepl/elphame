require "test_helper"

class StarRatingsControllerTest < ActionDispatch::IntegrationTest
  test "create rating requires authentication" do
    post post_star_rating_url(posts(:one)), params: { rating: 3.5 }
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end

  test "create rating when signed in" do
    sign_in_regular_user
    assert_difference("StarRating.count") do
      post post_star_rating_url(posts(:one)), params: { rating: 4.0 }, as: :turbo_stream
    end
    assert_response :success
  end

  test "show rating" do
    get post_star_rating_url(posts(:one))
    assert_response :success
  end

  test "destroy rating requires authentication" do
    delete post_star_rating_url(posts(:two))
    assert_response :redirect
    assert_redirected_to new_user_session_path
  end
end
