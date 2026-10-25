# Lets an agent act as its user by appending ?bot_key=... to any request.
#
# The key signs the request in through Devise and exempts it from CSRF
# verification, so the same controllers serve browsers and agents. Included by
# both the public ApplicationController and the Administrate base controller.
module BotKeyAuthentication
  extend ActiveSupport::Concern

  included do
    protect_from_forgery with: :exception, unless: :forgery_protection_exempt?
    before_action :authenticate_by_bot_key
  end

  private

  # CSRF guards a browser session's cookie. A bot key is its own credential,
  # and a JSON request with no session has no ambient authority to forge, so
  # neither needs a token; the latter then reaches authentication and gets a
  # 401 rather than a CSRF failure.
  def forgery_protection_exempt?
    bot_key_present? || (request.format.json? && !user_signed_in?)
  end

  def authenticate_by_bot_key
    return unless bot_key_present?
    if user = User.authenticate_bot(params[:bot_key].to_s.strip)
      sign_in(user) unless user_signed_in?
      @authenticated_by_bot_key = true
    end
  end

  def authenticated_by_bot_key?
    @authenticated_by_bot_key == true
  end

  def bot_key_present?
    params[:bot_key].present?
  end

  def render_json_error(message, status:)
    render json: { error: message }, status: status
  end
end
