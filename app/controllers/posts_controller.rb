class PostsController < ApplicationController
  before_action :set_post, only: [ :edit, :update, :destroy ]
  before_action :authorize_owner!, only: [ :edit, :update, :destroy ]

  def create
    @discussion = Discussion.find(params[:discussion_id])
    @post = @discussion.posts.new(post_params)

    # Associate with current user if logged in
    @post.user = current_user if user_signed_in?

    if @post.save
      deliver_webhooks_for(@post)

      respond_to do |format|
        format.html { redirect_to discussion_path(@discussion, anchor: "post-#{@post.id}"), notice: "Your whisper echoes in the void." }
        format.json { render json: { id: @post.id, content: @post.content, author: @post.display_name, discussion_id: @discussion.id, created_at: @post.created_at }, status: :created }
      end
    else
      respond_to do |format|
        format.html { redirect_to discussion_path(@discussion), alert: "The shadows reject your offering." }
        format.json { render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @discussion = @post.discussion
  end

  def update
    if @post.update(post_update_params)
      redirect_to discussion_path(@post.discussion, anchor: "post-#{@post.id}"),
                  notice: "Your words reshape the shadows."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    discussion = @post.discussion
    post_id = @post.id
    @post.destroy

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.remove("post-#{post_id}")
      }
      format.html { redirect_to discussion_path(discussion), notice: "Your echo fades into silence." }
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_owner!
    unless @post.user == current_user || current_user&.admin?
      redirect_to discussion_path(@post.discussion), alert: "You cannot unmake another's voice."
    end
  end

  def post_params
    params.require(:post).permit(:content, :image, :author_name, :quoted_post_id, :soft_username)
  end

  def post_update_params
    params.require(:post).permit(:content)
  end

  def deliver_webhooks_for(post)
    return if post.content.blank?
    mentioned_usernames = post.content.scan(/\B@([A-Za-z][A-Za-z0-9_-]*)/).flatten
    return if mentioned_usernames.empty?

    User.where(username: mentioned_usernames).where.not(bot_token: nil).excluding(post.user).find_each do |bot|
      bot.deliver_webhook_later(post)
    end
  end
end
