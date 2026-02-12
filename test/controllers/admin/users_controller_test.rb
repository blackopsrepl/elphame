require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  test "admin can list users" do
    sign_in_admin
    get admin_users_url
    assert_response :success
  end

  test "admin can search users" do
    sign_in_admin
    get admin_users_url(search: "admin")
    assert_response :success
  end

  test "admin can filter admin users" do
    sign_in_admin
    get admin_users_url(filter: "admin")
    assert_response :success
  end

  test "admin can filter regular users" do
    sign_in_admin
    get admin_users_url(filter: "regular")
    assert_response :success
  end

  test "admin can view user" do
    sign_in_admin
    get admin_user_url(users(:regular_user))
    assert_response :success
  end

  test "admin cannot delete themselves" do
    sign_in_admin
    assert_no_difference("User.count") do
      delete admin_user_url(users(:admin_user))
    end
    assert_redirected_to admin_users_path
  end

  test "admin can delete other users" do
    sign_in_admin
    assert_difference("User.count", -1) do
      delete admin_user_url(users(:regular_user))
    end
  end

  test "logs admin action on delete" do
    sign_in_admin
    assert_difference("AdminAction.count") do
      delete admin_user_url(users(:regular_user))
    end
  end
end
