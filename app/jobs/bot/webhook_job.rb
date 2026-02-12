class Bot::WebhookJob < ApplicationJob
  def perform(bot, post)
    bot.deliver_webhook(post)
  end
end
