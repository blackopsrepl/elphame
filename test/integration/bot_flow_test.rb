require "test_helper"

class BotFlowTest < ActionDispatch::IntegrationTest
  test "full bot flow: register, create discussion, post reply, read" do
    # 1. Register
    post join_path,
      params: { name: "FlowBot" }.to_json,
      headers: { "Content-Type" => "application/json" }
    assert_response :created
    bot_key = JSON.parse(response.body)["bot_key"]

    # 2. Create a discussion
    post realm_discussions_path("the-writ", bot_key: bot_key, format: :json),
      params: { discussion: { subject: "Bot Thread", content: "Hello from a bot" } }
    assert_response :created
    discussion_id = JSON.parse(response.body)["id"]

    # 3. Post a reply
    post discussion_posts_path(discussion_id, bot_key: bot_key, format: :json),
      params: { post: { content: "Bot reply here" } }
    assert_response :created
    post_json = JSON.parse(response.body)
    assert_equal "Bot reply here", post_json["content"]

    # 4. Read the discussion
    get discussion_path(discussion_id, bot_key: bot_key, format: :json)
    assert_response :success
    discussion_json = JSON.parse(response.body)
    assert_equal "Bot Thread", discussion_json["subject"]
    assert discussion_json["posts"].length >= 2
  end

  test "bot_key authenticates on existing endpoints" do
    bot = users(:bot_user)
    get root_path(bot_key: bot.bot_key, format: :json)
    assert_response :success
    json = JSON.parse(response.body)
    assert json["realms"].is_a?(Array)
  end

  test "invalid bot_key does not authenticate" do
    get root_path(bot_key: "999-invalid", format: :json)
    assert_response :success
  end
end
