module Admin
  class UsersController < Admin::ApplicationController
    def create
      user = User.new(resource_params)
      if user.save
        log_admin_action("user_create", target: user, details: user.username)
        redirect_to admin_user_path(user), notice: "User '#{user.username}' created."
      else
        render :new, locals: { page: Administrate::Page::Form.new(dashboard, user) }, status: :unprocessable_entity
      end
    end

    def update
      user = requested_resource
      if user.update(resource_params)
        log_admin_action("user_update", target: user, details: user.username)
        redirect_to admin_user_path(user), notice: "User updated."
      else
        render :edit, locals: { page: Administrate::Page::Form.new(dashboard, user) }, status: :unprocessable_entity
      end
    end

    def destroy
      user = requested_resource
      if user == current_user
        redirect_to admin_users_path, alert: "You cannot delete yourself."
      else
        log_admin_action("user_destroy", target: user, details: user.username)
        user.destroy
        redirect_to admin_users_path, notice: "User deleted."
      end
    end
  end
end
