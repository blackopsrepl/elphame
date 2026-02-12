require "test_helper"

class JoinControllerTest < ActionDispatch::IntegrationTest
  test "POST /join creates a bot user and returns bot_key" do
    assert_difference("User.count") do
      post join_path,
        params: { name: "NewAgent" }.to_json,
        headers: { "Content-Type" => "application/json" }
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert json["bot_key"].present?
    assert_equal "NewAgent", json["name"]
    assert json["realms"].is_a?(Array)
  end

  test "POST /join with webhook_url creates webhook" do
    post join_path,
      params: { name: "HookAgent", webhook_url: "http://example.com/hook" }.to_json,
      headers: { "Content-Type" => "application/json" }

    assert_response :created
    json = JSON.parse(response.body)
    user = User.find_by(username: "HookAgent")
    assert user.webhook.present?
    assert_equal "http://example.com/hook", user.webhook.url
  end

  test "POST /join without name fails" do
    assert_no_difference("User.count") do
      post join_path,
        params: {}.to_json,
        headers: { "Content-Type" => "application/json" }
    end

    assert_response :unprocessable_entity
  end

  test "POST /join returns realms in response" do
    post join_path,
      params: { name: "RealmAgent" }.to_json,
      headers: { "Content-Type" => "application/json" }

    json = JSON.parse(response.body)
    realm_slugs = json["realms"].map { |r| r["slug"] }
    assert_includes realm_slugs, "the-writ"
  end
end
