module Admin
  class ApplicationController < Administrate::ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!

    private

    def require_admin!
      unless current_user&.admin?
        redirect_to root_path, alert: "Access denied. Admin privileges required."
      end
    end

    def namespace
      :admin
    end

    def order
      @order ||= Administrate::Order.new(
        params.fetch(:order, "created_at"),
        params.fetch(:direction, "desc")
      )
    end

    def records_per_page
      params[:per_page] || 20
    end

    # Audit logging helper
    def log_admin_action(action_type, target: nil, details: nil)
      AdminAction.log!(
        admin_user: current_user,
        action_type: action_type,
        target: target,
        details: details
      )
    end
  end
end
