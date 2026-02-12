require "test_helper"

class RealmsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
  end

  test "should get show" do
    realm = realms(:the_writ)
    get realm_url(realm.slug)
    assert_response :success
  end
end
