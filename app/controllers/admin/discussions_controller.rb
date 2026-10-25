module Admin
  class DiscussionsController < Admin::ApplicationController
    def create
      discussion = Discussion.new(resource_params)
      discussion.user = current_user
      if discussion.save
        log_admin_action("discussion_create", target: discussion, details: discussion.subject.presence || "untitled ##{discussion.id}")
        respond_with_saved(discussion, notice: "Discussion created.", status: :created)
      else
        respond_with_invalid(discussion, :new)
      end
    end

    def update
      discussion = requested_resource
      if discussion.update(resource_params)
        log_admin_action("discussion_update", target: discussion, details: discussion.subject.presence || "untitled ##{discussion.id}")
        respond_with_saved(discussion, notice: "Discussion updated.")
      else
        respond_with_invalid(discussion, :edit)
      end
    end

    def destroy
      discussion = requested_resource
      log_admin_action("discussion_destroy", target: discussion, details: discussion.subject.presence || "untitled ##{discussion.id}")
      discussion.destroy
      respond_with_destroyed(admin_discussions_path, notice: "Discussion deleted.")
    end

    def pin
      discussion = Discussion.find(params[:id])

      if discussion.pinned?
        discussion.unpin!
        log_admin_action("discussion_unpin", target: discussion, details: discussion.subject)
        respond_with_curation(discussion, "Discussion unpinned.")
      else
        discussion.pin!(current_user)
        log_admin_action("discussion_pin", target: discussion, details: discussion.subject)
        respond_with_curation(discussion, "Discussion pinned.")
      end
    end

    def boost
      discussion = Discussion.find(params[:id])
      amount = params[:amount]&.to_i || 10
      discussion.increment!(:manual_boost_score, amount)
      log_admin_action("discussion_boost", target: discussion, details: "#{discussion.subject} (+#{amount})")
      respond_with_curation(discussion, "Discussion boosted by #{amount} points.")
    end

    private

    def respond_with_curation(discussion, notice)
      respond_to do |format|
        format.html { redirect_back fallback_location: admin_discussions_path, notice: notice }
        format.json { render json: admin_resource_json(discussion.reload) }
      end
    end
  end
end
