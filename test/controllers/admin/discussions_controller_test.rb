require "test_helper"

class Admin::DiscussionsControllerTest < ActionDispatch::IntegrationTest
  test "admin can list discussions" do
    sign_in_admin
    get admin_discussions_url
    assert_response :success
  end

  test "admin can search discussions" do
    sign_in_admin
    get admin_discussions_url(search: "test")
    assert_response :success
  end

  test "admin can filter pinned discussions" do
    sign_in_admin
    get admin_discussions_url(filter: "pinned")
    assert_response :success
  end

  test "admin can filter by realm" do
    sign_in_admin
    get admin_discussions_url(filter: "realm", realm_id: realms(:the_writ).id)
    assert_response :success
  end

  test "admin can view discussion" do
    sign_in_admin
    get admin_discussion_url(discussions(:one))
    assert_response :success
  end

  test "admin can pin discussion" do
    sign_in_admin
    post pin_admin_discussion_url(discussions(:two))
    assert_redirected_to admin_discussions_path
  end

  test "admin can boost discussion" do
    sign_in_admin
    post boost_admin_discussion_url(discussions(:two))
    assert_redirected_to admin_discussions_path
    discussions(:two).reload
    assert_equal 10, discussions(:two).manual_boost_score
  end

  test "admin can delete discussion" do
    sign_in_admin
    discussion = discussions(:two)
    assert_difference("Discussion.count", -1) do
      delete admin_discussion_url(discussion)
    end
    assert_redirected_to admin_discussions_path
  end

  test "logs admin action on delete" do
    sign_in_admin
    assert_difference("AdminAction.count") do
      delete admin_discussion_url(discussions(:two))
    end
  end
end
