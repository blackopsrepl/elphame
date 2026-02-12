require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get admin_root_url
    assert_response :redirect
  end

  test "requires admin role" do
    sign_in_regular_user
    get admin_root_url
    assert_response :redirect
    assert_redirected_to root_path
  end

  test "admin can access dashboard" do
    sign_in_admin
    get admin_root_url
    assert_response :success
  end
end
