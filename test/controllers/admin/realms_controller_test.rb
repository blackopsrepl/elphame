require "test_helper"

class Admin::RealmsControllerTest < ActionDispatch::IntegrationTest
  test "requires admin" do
    get admin_realms_url
    assert_response :redirect
  end

  test "admin can list realms" do
    sign_in_admin
    get admin_realms_url
    assert_response :success
  end

  test "admin can view realm" do
    sign_in_admin
    get admin_realm_url(realms(:the_writ))
    assert_response :success
  end

  test "admin can create realm" do
    sign_in_admin
    assert_difference("Realm.count") do
      post admin_realms_url, params: {
        realm: { name: "New Realm", slug: "new-realm", description: "A brand new realm", icon: "🆕", color: "#ff0000" }
      }
    end
    assert_response :redirect
  end

  test "admin can update realm" do
    sign_in_admin
    realm = realms(:the_writ)
    patch admin_realm_url(realm), params: { realm: { icon: "📜" } }
    assert_response :redirect
  end

  test "admin can delete realm" do
    sign_in_admin
    realm = realms(:random)
    assert_difference("Realm.count", -1) do
      delete admin_realm_url(realm)
    end
  end

  test "regular user cannot access admin realms" do
    sign_in_regular_user
    get admin_realms_url
    assert_redirected_to root_path
  end
end
