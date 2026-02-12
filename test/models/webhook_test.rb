require "test_helper"

class WebhookTest < ActiveSupport::TestCase
  test "belongs to user" do
    webhook = webhooks(:testbot)
    assert_equal users(:bot_user), webhook.user
  end

  test "webhook url is stored" do
    webhook = webhooks(:testbot)
    assert_equal "http://example.com/webhook", webhook.url
  end
end
