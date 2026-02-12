require "test_helper"

class Admin::AdminActionsControllerTest < ActionDispatch::IntegrationTest
  test "admin can view audit log" do
    sign_in_admin
    get admin_admin_actions_url
    assert_response :success
  end

  test "create route does not exist for audit log" do
    sign_in_admin
    post admin_admin_actions_url
    assert_response :not_found
  end

  test "regular user cannot view audit log" do
    sign_in_regular_user
    get admin_admin_actions_url
    assert_redirected_to root_path
  end
end
