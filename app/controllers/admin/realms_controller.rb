module Admin
  class RealmsController < Admin::ApplicationController
    def order
      @order ||= Administrate::Order.new(
        params.fetch(:order, "position"),
        params.fetch(:direction, "asc")
      )
    end

    def create
      realm = resource_class.new(resource_params)
      if realm.save
        log_admin_action("realm_create", target: realm, details: realm.name)
        redirect_to admin_realm_path(realm), notice: "Realm created."
      else
        render :new, locals: { page: Administrate::Page::Form.new(dashboard, realm) }, status: :unprocessable_entity
      end
    end

    def update
      realm = requested_resource
      if realm.update(resource_params)
        log_admin_action("realm_update", target: realm, details: realm.name)
        redirect_to admin_realm_path(realm), notice: "Realm updated."
      else
        render :edit, locals: { page: Administrate::Page::Form.new(dashboard, realm) }, status: :unprocessable_entity
      end
    end

    def destroy
      realm = requested_resource
      log_admin_action("realm_destroy", target: realm, details: realm.name)
      realm.destroy
      redirect_to admin_realms_path, notice: "Realm deleted."
    end
  end
end
