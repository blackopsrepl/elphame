class DiscussionsController < ApplicationController
  before_action :authenticate_user!, only: [ :pin, :boost, :edit, :update, :destroy ]
  before_action :set_discussion, only: [ :show, :edit, :update, :destroy, :pin, :boost ]
  before_action :authorize_owner!, only: [ :edit, :update, :destroy ]
  before_action :require_admin!, only: [ :pin, :boost ]

  def index
    @realm = Realm.find_by!(slug: params[:realm_slug])

    respond_to do |format|
      format.html { redirect_to realm_path(@realm.slug, request.query_parameters.slice("sort", "label", "page")) }
      format.json do
        discussions = @realm.discussions.listed(sort: params[:sort], label: params[:label])
                            .includes(:labels, :realm).with_attached_image.page(params[:page]).per(25)
        render json: discussions_listing_json(@realm, discussions)
      end
    end
  end

  def show
    @posts = @discussion.posts.with_attached_image.order(created_at: :asc)
    @post = Post.new

    respond_to do |format|
      format.html
      format.json do
        render json: {
          **discussion_json(@discussion),
          posts: @posts.map { |p| post_json(p) }
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
      respond_to do |format|
        format.html { redirect_to discussion_path(@discussion), notice: "Thread reshaped by shadow-craft." }
        format.json { render json: discussion_json(@discussion.reload) }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @discussion.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    realm_slug = @discussion.realm.slug
    @discussion.destroy
    respond_to do |format|
      format.html { redirect_to realm_path(realm_slug), notice: "Thread unraveled into the void." }
      format.json { head :no_content }
    end
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
    if @discussion.pinned?
      @discussion.unpin!
      AdminAction.log!(admin_user: current_user, action_type: "discussion_unpin", target: @discussion, details: @discussion.subject)
      message = "Thread unpinned from the aether"
    else
      @discussion.pin!(current_user)
      AdminAction.log!(admin_user: current_user, action_type: "discussion_pin", target: @discussion, details: @discussion.subject)
      message = "Thread pinned to the firmament"
    end

    respond_with_curation(message)
  end

  def boost
    boost_amount = params[:amount]&.to_i || 10
    @discussion.increment!(:manual_boost_score, boost_amount)
    AdminAction.log!(admin_user: current_user, action_type: "discussion_boost", target: @discussion, details: "#{@discussion.subject} (+#{boost_amount})")

    respond_with_curation("Thread boosted by #{boost_amount} essence points")
  end

  private

  def set_discussion
    @discussion = Discussion.find(params[:id])
  end

  def authorize_owner!
    return if @discussion.user == current_user || current_user&.admin?

    respond_to do |format|
      format.html { redirect_to discussion_path(@discussion), alert: "You cannot reshape another's shadows." }
      format.json { render_json_error("You can only change your own discussions", status: :forbidden) }
    end
  end

  def require_admin!
    return if current_user.admin?

    respond_to do |format|
      format.any(:html, :turbo_stream) { redirect_back fallback_location: discussion_path(@discussion), alert: "Only shadow-lords may #{action_name}." }
      format.json { render_json_error("Only admins may #{action_name} discussions", status: :forbidden) }
    end
  end

  def respond_with_curation(message)
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace("discussion-header", partial: "discussions/header", locals: { discussion: @discussion }),
          turbo_stream.update("flash-messages", partial: "shared/flash", locals: { notice: message })
        ]
      }
      format.html { redirect_back fallback_location: discussion_path(@discussion), notice: message }
      format.json { render json: discussion_json(@discussion.reload) }
    end
  end

  def discussion_params
    params.require(:discussion).permit(:subject, :content, :image, :author_name, :soft_username)
  end

  def discussion_update_params
    params.require(:discussion).permit(:subject, :content)
  end
end
