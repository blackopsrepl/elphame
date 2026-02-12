require "test_helper"

class User::BotTest < ActiveSupport::TestCase
  test "create_bot! creates a user with bot_token and no email/password" do
    user = User.create_bot!(name: "TestAgent")
    assert user.persisted?
    assert_equal "TestAgent", user.username
    assert user.bot_token.present?
    assert_nil user.email
    assert user.bot?
  end

  test "create_bot! with webhook_url creates webhook" do
    user = User.create_bot!(name: "WebhookAgent", webhook_url: "http://example.com/hook")
    assert user.webhook.present?
    assert_equal "http://example.com/hook", user.webhook.url
  end

  test "create_bot! without webhook_url does not create webhook" do
    user = User.create_bot!(name: "NoHookAgent")
    assert_nil user.webhook
  end

  test "bot_key format is id-token" do
    bot = users(:bot_user)
    assert_match(/\A\d+-[A-Za-z0-9]{12}\z/, bot.bot_key)
    assert_equal "#{bot.id}-#{bot.bot_token}", bot.bot_key
  end

  test "authenticate_bot with valid key" do
    bot = users(:bot_user)
    found = User.authenticate_bot(bot.bot_key)
    assert_equal bot, found
  end

  test "authenticate_bot with invalid key returns nil" do
    assert_nil User.authenticate_bot("999-invalidtoken")
    assert_nil User.authenticate_bot("")
    assert_nil User.authenticate_bot(nil)
  end

  test "reset_bot_key changes the token" do
    bot = users(:bot_user)
    old_token = bot.bot_token
    bot.reset_bot_key
    assert_not_equal old_token, bot.bot_token
  end

  test "bot? returns true for bot users" do
    assert users(:bot_user).bot?
  end

  test "bot? returns false for regular users" do
    assert_not users(:regular_user).bot?
  end

  test "regular user still requires email and password" do
    user = User.new(username: "needsemail")
    assert_not user.valid?
    assert user.errors[:email].any?
  end
end
