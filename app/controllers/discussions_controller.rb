class DiscussionsController < ApplicationController
  before_action :authenticate_user!, only: [ :pin, :boost, :edit, :update, :destroy ]
  before_action :set_discussion, only: [ :show, :edit, :update, :destroy, :pin, :boost ]
  before_action :authorize_owner!, only: [ :edit, :update, :destroy ]

  def index
    @realm = Realm.find_by(slug: params[:realm_slug])
    @discussions = @realm.discussions

    # Sort selection
    case params[:sort]
    when "newest"
      @discussions = @discussions.by_newest
    when "activity"
      @discussions = @discussions.by_recent_activity
    when "replies"
      @discussions = @discussions.by_most_replies
    when "stars"
      @discussions = @discussions.by_stars
    else
      # Default: smart activity score
      @discussions = @discussions.by_activity_score
    end

    # Label filtering
    if params[:label].present?
      @discussions = @discussions.with_label(params[:label])
    end

    @discussions = @discussions.includes(:labels, :realm).page(params[:page]).per(25)
  end

  def show
    @posts = @discussion.posts.order(created_at: :asc)
    @post = Post.new

    respond_to do |format|
      format.html
      format.json do
        render json: {
          **discussion_json(@discussion),
          posts: @posts.map { |p|
            { id: p.id, content: p.content, author: p.display_name, created_at: p.created_at }
          }
        }
      end
    end
  end

  def edit
    # @discussion set by before_action
  end

  def update
    if @discussion.update(discussion_update_params)
      # Update the thread type label if provided
      if params[:thread_type].present?
        @discussion.set_thread_type(params[:thread_type], user: current_user)
      end
      redirect_to discussion_path(@discussion), notice: "Thread reshaped by shadow-craft."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    realm_slug = @discussion.realm.slug
    @discussion.destroy
    redirect_to realm_path(realm_slug), notice: "Thread unraveled into the void."
  end

  def new
    @realm = Realm.find_by!(slug: params[:realm_slug])
    @discussion = @realm.discussions.new
  end

  def create
    @realm = Realm.find_by!(slug: params[:realm_slug])
    @discussion = @realm.discussions.new(discussion_params)

    # Associate with current user if logged in
    @discussion.user = current_user if user_signed_in?

    if @discussion.save
      # Set the thread type label
      @discussion.set_thread_type(params[:thread_type], user: current_user)

      respond_to do |format|
        format.html { redirect_to discussion_path(@discussion), notice: "Thread conjured into being." }
        format.json { render json: discussion_json(@discussion), status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @discussion.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def pin
    unless current_user.admin?
      redirect_back fallback_location: discussion_path(@discussion), alert: "Only shadow-lords may pin."
      return
    end

    if @discussion.pinned?
      @discussion.unpin!
      AdminAction.log!(admin_user: current_user, action_type: "discussion_unpin", target: @discussion, details: @discussion.subject)
      message = "Thread unpinned from the aether"
    else
      @discussion.pin!(current_user)
      AdminAction.log!(admin_user: current_user, action_type: "discussion_pin", target: @discussion, details: @discussion.subject)
      message = "Thread pinned to the firmament"
    end

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace("discussion-header", partial: "discussions/header", locals: { discussion: @discussion }),
          turbo_stream.update("flash-messages", partial: "shared/flash", locals: { notice: message })
        ]
      }
      format.html { redirect_back fallback_location: discussion_path(@discussion), notice: message }
    end
  end

  def boost
    unless current_user.admin?
      redirect_back fallback_location: discussion_path(@discussion), alert: "Only shadow-lords may boost."
      return
    end

    boost_amount = params[:amount]&.to_i || 10
    @discussion.increment!(:manual_boost_score, boost_amount)
    AdminAction.log!(admin_user: current_user, action_type: "discussion_boost", target: @discussion, details: "#{@discussion.subject} (+#{boost_amount})")

    message = "Thread boosted by #{boost_amount} essence points"
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace("discussion-header", partial: "discussions/header", locals: { discussion: @discussion }),
          turbo_stream.update("flash-messages", partial: "shared/flash", locals: { notice: message })
        ]
      }
      format.html { redirect_back fallback_location: discussion_path(@discussion), notice: message }
    end
  end

  private

  def set_discussion
    @discussion = Discussion.find(params[:id])
  end

  def authorize_owner!
    unless @discussion.user == current_user || current_user&.admin?
      redirect_to discussion_path(@discussion), alert: "You cannot reshape another's shadows."
    end
  end

  def discussion_params
    params.require(:discussion).permit(:subject, :content, :image, :author_name, :soft_username)
  end

  def discussion_update_params
    params.require(:discussion).permit(:subject, :content)
  end

  def discussion_json(discussion)
    {
      id: discussion.id,
      subject: discussion.subject,
      content: discussion.content,
      realm: { id: discussion.realm.id, name: discussion.realm.name, slug: discussion.realm.slug },
      author: discussion.display_name,
      created_at: discussion.created_at
    }
  end
end
