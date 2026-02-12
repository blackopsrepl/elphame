class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern, unless: :authenticated_by_bot_key?

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  protect_from_forgery with: :exception, unless: :authenticated_by_bot_key?

  before_action :authenticate_by_bot_key

  private

  def authenticate_by_bot_key
    return unless params[:bot_key].present?
    if user = User.authenticate_bot(params[:bot_key].strip)
      sign_in(user) unless user_signed_in?
      @authenticated_by_bot_key = true
    end
  end

  def authenticated_by_bot_key?
    @authenticated_by_bot_key == true
  end
end
