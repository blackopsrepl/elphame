module Admin
  class UsersController < Admin::ApplicationController
    def create
      user = User.new(resource_params)
      if user.save
        log_admin_action("user_create", target: user, details: user.username)
        respond_with_saved(user, notice: "User '#{user.username}' created.", status: :created)
      else
        respond_with_invalid(user, :new)
      end
    end

    def update
      user = requested_resource
      if user.update(resource_params)
        log_admin_action("user_update", target: user, details: user.username)
        respond_with_saved(user, notice: "User updated.")
      else
        respond_with_invalid(user, :edit)
      end
    end

    def destroy
      user = requested_resource
      if user == current_user
        respond_to do |format|
          format.html { redirect_to admin_users_path, alert: "You cannot delete yourself." }
          format.json { render_json_error("You cannot delete yourself", status: :unprocessable_entity) }
        end
      else
        log_admin_action("user_destroy", target: user, details: user.username)
        user.destroy
        respond_with_destroyed(admin_users_path, notice: "User deleted.")
      end
    end
  end
end
