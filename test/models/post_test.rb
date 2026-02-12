require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "valid post" do
    post = Post.new(discussion: discussions(:one), content: "Test reply content")
    assert post.valid?
  end

  test "requires content" do
    post = Post.new(discussion: discussions(:one))
    assert_not post.valid?
    assert_includes post.errors[:content], "can't be blank"
  end

  test "content max length 2000" do
    post = Post.new(discussion: discussions(:one), content: "a" * 2001)
    assert_not post.valid?
  end

  test "update_star_cache! recalculates from star_ratings" do
    post = posts(:two)
    post.update_star_cache!
    expected_total = post.star_ratings.sum(:rating)
    expected_count = post.star_ratings.count
    assert_equal expected_total, post.star_total_cache
    assert_equal expected_count, post.star_count_cache
  end

  test "average_stars returns 0.0 when no ratings" do
    post = posts(:one)
    assert_equal 0.0, post.average_stars
  end

  test "star_rating_for returns nil for non-rated user" do
    post = posts(:one)
    assert_nil post.star_rating_for(users(:admin_user))
  end

  test "display_name returns Anonymous for anonymous post" do
    post = posts(:one)
    assert_equal "Anonymous", post.display_name
  end

  test "display_name returns username for user post" do
    post = posts(:admin_post)
    assert_equal "adminuser", post.display_name
  end
end
