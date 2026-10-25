module Admin
  class ApplicationController < Administrate::ApplicationController
    include BotKeyAuthentication
    include JsonRepresentations

    before_action :authenticate_user!
    before_action :require_admin!

    # Every admin resource answers JSON for an authenticated admin, including
    # an admin bot authenticating with ?bot_key=. The fields are the ones the
    # resource's dashboard shows on its admin page.
    def index
      return super unless request.format.json?

      authorize_resource(resource_class)
      resources = filter_resources(scoped_resource, search_term: params[:search].to_s.strip)
      resources = paginate_resources(order.apply(apply_collection_includes(resources)))
      render json: {
        resources: resources.map { |resource| admin_resource_json(resource, include_collections: false) },
        meta: page_meta_json(resources)
      }
    end

    def show
      return super unless request.format.json?

      render json: admin_resource_json(requested_resource)
    end

    private

    def require_admin!
      return if current_user&.admin?

      respond_to do |format|
        format.json { render_json_error("Admin privileges required", status: :forbidden) }
        format.any { redirect_to root_path, alert: "Access denied. Admin privileges required." }
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

    def respond_with_saved(resource, notice:, status: :ok, location: [ namespace, resource ])
      respond_to do |format|
        format.html { redirect_to location, notice: notice }
        format.json { render json: admin_resource_json(resource), status: status }
      end
    end

    def respond_with_invalid(resource, template)
      respond_to do |format|
        format.html do
          render template, locals: { page: Administrate::Page::Form.new(dashboard, resource) }, status: :unprocessable_entity
        end
        format.json { render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity }
      end
    end

    def respond_with_destroyed(location, notice:)
      respond_to do |format|
        format.html { redirect_to location, notice: notice }
        format.json { head :no_content }
      end
    end

    # Serialises a record through its dashboard: belongs_to fields become
    # `<name>_id`, has_many fields become `<singular>_ids` (show only, to keep
    # collection pages cheap), and password fields are never emitted.
    def admin_resource_json(resource, include_collections: true)
      dashboard_attribute_names.each_with_object({}) do |name, json|
        field = dashboard.attribute_types.fetch(name)
        field = field.deferred_class if field.respond_to?(:deferred_class)

        if field <= Administrate::Field::Password
          next
        elsif field <= Administrate::Field::BelongsTo
          json[:"#{name}_id"] = resource.public_send(resource.class.reflect_on_association(name).foreign_key)
        elsif field <= Administrate::Field::HasMany
          json[:"#{name.to_s.singularize}_ids"] = resource.public_send(name).ids if include_collections
        else
          json[name] = resource.public_send(name)
        end
      end
    end

    def dashboard_attribute_names
      attributes = dashboard.show_page_attributes
      attributes.is_a?(Hash) ? attributes.values.flatten : attributes
    end
  end
end
