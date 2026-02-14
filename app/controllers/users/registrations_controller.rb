module Users
  class RegistrationsController < Devise::RegistrationsController
    skip_before_action :authenticate_scope!, if: :bot_key_present?

    before_action :configure_sign_up_params, only: [ :create ]
    before_action :configure_account_update_params, only: [ :update ]
    before_action :ensure_authenticated_for_update, only: [ :update ]

    # Override update to add JSON response support
    def update
      self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
      prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

      resource_updated = update_resource(resource, account_update_params)
      yield resource if block_given?
      if resource_updated
        bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?

        respond_to do |format|
          format.html do
            set_flash_message_for_update(resource, prev_unconfirmed_email)
            redirect_to after_update_path_for(resource)
          end
          format.json do
            render json: {
              id: resource.id,
              username: resource.username,
              email: resource.email,
              avatar_url: resource.avatar.attached? ? url_for(resource.avatar_thumbnail) : nil,
              admin: resource.admin
            }
          end
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end

    protected

    def ensure_authenticated_for_update
      unless user_signed_in?
        respond_to do |format|
          format.html { redirect_to new_user_session_path }
          format.json { render json: { error: "You need to sign in or sign up before continuing." }, status: :unauthorized }
        end
      end
    end

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
      # Check if user is trying to change password
      password_change = params[:password].present? || params[:password_confirmation].present?

      if password_change
        # Update with password (requires current_password for validation)
        resource.update_with_password(params)
      elsif params[:current_password].present?
        # Not changing password but current_password provided - verify it and update other fields
        current_password = params.delete(:current_password)
        params.delete(:password)
        params.delete(:password_confirmation)

        # Verify current password
        if resource.valid_password?(current_password)
          resource.update_without_password(params)
        else
          resource.errors.add(:current_password, :invalid)
          false
        end
      else
        # No password change and no current_password - update without password
        params.delete(:password)
        params.delete(:password_confirmation)
        params.delete(:current_password)
        resource.update_without_password(params)
      end
    end
  end
end
