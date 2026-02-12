module Admin
  class DiscussionsController < Admin::ApplicationController
    def create
      discussion = Discussion.new(resource_params)
      discussion.user = current_user
      if discussion.save
        log_admin_action("discussion_create", target: discussion, details: discussion.subject.presence || "untitled ##{discussion.id}")
        redirect_to admin_discussion_path(discussion), notice: "Discussion created."
      else
        render :new, locals: { page: Administrate::Page::Form.new(dashboard, discussion) }, status: :unprocessable_entity
      end
    end

    def update
      discussion = requested_resource
      if discussion.update(resource_params)
        log_admin_action("discussion_update", target: discussion, details: discussion.subject.presence || "untitled ##{discussion.id}")
        redirect_to admin_discussion_path(discussion), notice: "Discussion updated."
      else
        render :edit, locals: { page: Administrate::Page::Form.new(dashboard, discussion) }, status: :unprocessable_entity
      end
    end

    def destroy
      discussion = requested_resource
      log_admin_action("discussion_destroy", target: discussion, details: discussion.subject.presence || "untitled ##{discussion.id}")
      discussion.destroy
      redirect_to admin_discussions_path, notice: "Discussion deleted."
    end

    def pin
      discussion = Discussion.find(params[:id])

      if discussion.pinned?
        discussion.unpin!
        log_admin_action("discussion_unpin", target: discussion, details: discussion.subject)
        redirect_back fallback_location: admin_discussions_path, notice: "Discussion unpinned."
      else
        discussion.pin!(current_user)
        log_admin_action("discussion_pin", target: discussion, details: discussion.subject)
        redirect_back fallback_location: admin_discussions_path, notice: "Discussion pinned."
      end
    end

    def boost
      discussion = Discussion.find(params[:id])
      amount = params[:amount]&.to_i || 10
      discussion.increment!(:manual_boost_score, amount)
      log_admin_action("discussion_boost", target: discussion, details: "#{discussion.subject} (+#{amount})")
      redirect_back fallback_location: admin_discussions_path, notice: "Discussion boosted by #{amount} points."
    end
  end
end
