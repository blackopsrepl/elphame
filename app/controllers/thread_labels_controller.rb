class ThreadLabelsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_discussion

  def create
    label = Label.find(params[:label_id])

    if @discussion.add_label(label.name, user: current_user)
      AdminAction.log!(admin_user: current_user, action_type: "label_add", target: @discussion, details: "#{label.display_name} on #{@discussion.subject}")
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace("discussion-header", partial: "discussions/header", locals: { discussion: @discussion.reload }),
            turbo_stream.replace("label-picker", partial: "discussions/label_picker", locals: { discussion: @discussion })
          ]
        }
        format.html { redirect_back fallback_location: discussion_path(@discussion), notice: "Label #{label.display_name} added" }
      end
    else
      redirect_back fallback_location: root_path, alert: "Could not add label"
    end
  end

  def destroy
    label = Label.find(params[:label_id])

    if @discussion.remove_label(label.name)
      AdminAction.log!(admin_user: current_user, action_type: "label_remove", target: @discussion, details: "#{label.display_name} from #{@discussion.subject}")
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace("discussion-header", partial: "discussions/header", locals: { discussion: @discussion.reload }),
            turbo_stream.replace("label-picker", partial: "discussions/label_picker", locals: { discussion: @discussion })
          ]
        }
        format.html { redirect_back fallback_location: discussion_path(@discussion), notice: "Label #{label.display_name} removed" }
      end
    else
      redirect_back fallback_location: root_path, alert: "Could not remove label"
    end
  end

  private

  def set_discussion
    @discussion = Discussion.find(params[:discussion_id])
  end

  def require_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: "Only admins can manage labels."
    end
  end
end
