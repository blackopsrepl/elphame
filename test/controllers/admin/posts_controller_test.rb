require "test_helper"

class Admin::PostsControllerTest < ActionDispatch::IntegrationTest
  test "admin can list posts" do
    sign_in_admin
    get admin_posts_url
    assert_response :success
  end

  test "admin can view post" do
    sign_in_admin
    get admin_post_url(posts(:one))
    assert_response :success
  end

  test "admin can search posts" do
    sign_in_admin
    get admin_posts_url(search: "first post")
    assert_response :success
  end

  test "admin can filter starred posts" do
    sign_in_admin
    get admin_posts_url(filter: "starred")
    assert_response :success
  end

  test "admin can filter anonymous posts" do
    sign_in_admin
    get admin_posts_url(filter: "anonymous")
    assert_response :success
  end

  test "admin can delete post" do
    sign_in_admin
    assert_difference("Post.count", -1) do
      delete admin_post_url(posts(:two))
    end
    assert_redirected_to admin_posts_path
  end

  test "logs admin action on post delete" do
    sign_in_admin
    assert_difference("AdminAction.count") do
      delete admin_post_url(posts(:two))
    end
  end
end
