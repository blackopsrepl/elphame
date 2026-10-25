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
      respond_with_discussion_labels(discussion, "Label '#{label.display_name}' added.")
    end

    def create_standalone
      thread_label = ThreadLabel.new(resource_params)
      thread_label.applied_by_user = current_user
      thread_label.applied_at = Time.current
      if thread_label.save
        log_admin_action("label_add", target: thread_label.discussion, details: "#{thread_label.label.display_name} on #{thread_label.discussion.subject}")
        respond_with_saved(thread_label, notice: "Thread label created.", status: :created)
      else
        respond_with_invalid(thread_label, :new)
      end
    end

    def destroy_from_discussion
      discussion = Discussion.find(params[:discussion_id])
      label = Label.find(params[:label_id])
      discussion.remove_label(label.name)
      log_admin_action("label_remove", target: discussion, details: "#{label.display_name} from #{discussion.subject}")
      respond_with_discussion_labels(discussion, "Label '#{label.display_name}' removed.")
    end

    def destroy_standalone
      thread_label = requested_resource
      log_admin_action("label_remove", target: thread_label.discussion, details: "#{thread_label.label.display_name} from #{thread_label.discussion.subject}")
      thread_label.destroy
      respond_with_destroyed(admin_thread_labels_path, notice: "Thread label removed.")
    end

    def respond_with_discussion_labels(discussion, notice)
      respond_to do |format|
        format.html { redirect_to admin_discussion_path(discussion), notice: notice }
        format.json { render json: discussion_json(discussion.reload) }
      end
    end
  end
end
