module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [ :create ]
    before_action :configure_account_update_params, only: [ :update ]

    protected

    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [ :username, :avatar ])
    end

    def configure_account_update_params
      devise_parameter_sanitizer.permit(:account_update, keys: [ :username, :avatar ])
    end

    def after_sign_up_path_for(resource)
      root_path
    end

    def after_update_path_for(resource)
      edit_user_registration_path
    end

    # Override update to handle username changes with proper validation
    def update_resource(resource, params)
      # If password is blank, update without requiring password validation
      if params[:password].blank?
        params.delete(:password)
        params.delete(:password_confirmation)
        # current_password is only used for update_with_password, must be removed here
        params.delete(:current_password)

        # Update without password
        resource.update_without_password(params)
      else
        # Update with password (requires current_password for validation)
        resource.update_with_password(params)
      end
    end
  end
end
