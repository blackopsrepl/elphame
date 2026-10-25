module Admin
  class LabelsController < Admin::ApplicationController
    def create
      label = Label.new(resource_params)
      if label.save
        log_admin_action("label_create", target: label, details: label.display_name)
        respond_with_saved(label, notice: "Label '#{label.display_name}' created.", status: :created)
      else
        respond_with_invalid(label, :new)
      end
    end

    def update
      label = requested_resource
      if label.update(resource_params)
        log_admin_action("label_update", target: label, details: label.display_name)
        respond_with_saved(label, notice: "Label '#{label.display_name}' updated.")
      else
        respond_with_invalid(label, :edit)
      end
    end

    def destroy
      label = requested_resource
      log_admin_action("label_destroy", target: label, details: label.display_name)
      label.destroy
      respond_with_destroyed(admin_labels_path, notice: "Label deleted.")
    end

    private

    def order
      @order ||= Administrate::Order.new(
        params.fetch(:order, "category"),
        params.fetch(:direction, "asc")
      )
    end
  end
end
