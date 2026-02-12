module Admin
  class ThreadLabelsController < Admin::ApplicationController
    def create
      if params[:discussion_id].present?
        create_from_discussion
      else
        create_standalone
      end
    end

    def destroy
      if params[:discussion_id].present?
        destroy_from_discussion
      else
        destroy_standalone
      end
    end

    private

    def create_from_discussion
      discussion = Discussion.find(params[:discussion_id])
      label = Label.find(params[:label_id])
      discussion.add_label(label.name, user: current_user)
      log_admin_action("label_add", target: discussion, details: "#{label.display_name} on #{discussion.subject}")
      redirect_to admin_discussion_path(discussion), notice: "Label '#{label.display_name}' added."
    end

    def create_standalone
      thread_label = ThreadLabel.new(resource_params)
      thread_label.applied_by_user = current_user
      thread_label.applied_at = Time.current
      if thread_label.save
        log_admin_action("label_add", target: thread_label.discussion, details: "#{thread_label.label.display_name} on #{thread_label.discussion.subject}")
        redirect_to admin_thread_label_path(thread_label), notice: "Thread label created."
      else
        render :new, locals: { page: Administrate::Page::Form.new(dashboard, thread_label) }, status: :unprocessable_entity
      end
    end

    def destroy_from_discussion
      discussion = Discussion.find(params[:discussion_id])
      label = Label.find(params[:label_id])
      discussion.remove_label(label.name)
      log_admin_action("label_remove", target: discussion, details: "#{label.display_name} from #{discussion.subject}")
      redirect_to admin_discussion_path(discussion), notice: "Label '#{label.display_name}' removed."
    end

    def destroy_standalone
      thread_label = requested_resource
      log_admin_action("label_remove", target: thread_label.discussion, details: "#{thread_label.label.display_name} from #{thread_label.discussion.subject}")
      thread_label.destroy
      redirect_to admin_thread_labels_path, notice: "Thread label removed."
    end
  end
end
