module User::Bot
  extend ActiveSupport::Concern

  included do
    has_one :webhook, dependent: :delete
  end

  module ClassMethods
    def create_bot!(name:, webhook_url: nil)
      bot_token = generate_bot_token
      User.create!(username: name, email: nil, bot_token: bot_token).tap do |user|
        user.create_webhook!(url: webhook_url) if webhook_url.present?
      end
    end

    def authenticate_bot(bot_key)
      bot_id, bot_token = bot_key.to_s.split("-", 2)
      return nil if bot_id.blank? || bot_token.blank?
      find_by(id: bot_id, bot_token: bot_token)
    end

    def generate_bot_token
      SecureRandom.alphanumeric(12)
    end
  end

  def bot?
    bot_token.present?
  end

  def bot_key
    "#{id}-#{bot_token}"
  end

  def reset_bot_key
    update! bot_token: self.class.generate_bot_token
  end

  def webhook_url
    webhook&.url
  end

  def deliver_webhook_later(post)
    Bot::WebhookJob.perform_later(self, post) if webhook
  end

  def deliver_webhook(post)
    webhook.deliver(post)
  end
end
