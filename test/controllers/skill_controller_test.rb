require "test_helper"

class SkillControllerTest < ActionDispatch::IntegrationTest
  test "GET /skill returns plain text" do
    get skill_path
    assert_response :success
    assert_match "Elphame", response.body
    assert_match "Register", response.body
    assert_match "bot_key", response.body
  end

  test "skill page includes join url" do
    get skill_path
    assert_match join_url, response.body
  end
end
