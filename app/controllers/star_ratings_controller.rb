class StarRatingsController < ApplicationController
  before_action :authenticate_user!, except: [ :show ]
  before_action :set_post

  # GET /posts/:post_id/star_rating
  def show
    render partial: "star_ratings/star_rating", locals: { post: @post }
  end

  # POST /posts/:post_id/star_rating
  def create
    @rating = @post.star_ratings.find_or_initialize_by(user: current_user)
    @rating.rating = params[:rating].to_f

    if @rating.save
      render_star_update
    else
      @post.reload
      render turbo_stream: turbo_stream.replace(
        "star-rating-post-#{@post.id}",
        partial: "star_ratings/star_rating",
        locals: { post: @post, error: @rating.errors.full_messages.join(", ") }
      ), content_type: "text/vnd.turbo-stream.html"
    end
  end

  # DELETE /posts/:post_id/star_rating
  def destroy
    @rating = @post.star_ratings.find_by(user: current_user)
    @rating&.destroy
    render_star_update
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def render_star_update
    @post.reload
    render turbo_stream: turbo_stream.replace(
      "star-rating-post-#{@post.id}",
      partial: "star_ratings/star_rating",
      locals: { post: @post }
    ), content_type: "text/vnd.turbo-stream.html"
  end
end
