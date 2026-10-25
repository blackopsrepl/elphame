class StarRatingsController < ApplicationController
  before_action :authenticate_user!, except: [ :show ]
  before_action :set_post

  # GET /posts/:post_id/star_rating
  def show
    respond_to do |format|
      format.any(:html, :turbo_stream) { render partial: "star_ratings/star_rating", locals: { post: @post } }
      format.json { render json: rating_json }
    end
  end

  # POST /posts/:post_id/star_rating
  def create
    @rating = @post.star_ratings.find_or_initialize_by(user: current_user)
    @rating.rating = requested_rating

    if @rating.save
      render_star_update
    else
      @post.reload
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "star-rating-post-#{@post.id}",
            partial: "star_ratings/star_rating",
            locals: { post: @post, error: @rating.errors.full_messages.join(", ") }
          )
        end
        format.html { redirect_to @post.discussion }
        format.json { render json: { errors: @rating.errors.full_messages }, status: :unprocessable_entity }
      end
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

  # The browser posts a bare `rating`; API clients may also nest it as
  # `star_rating[rating]`.
  def requested_rating
    (params[:rating] || params.dig(:star_rating, :rating)).to_f
  end

  def rating_json
    {
      post_id: @post.id,
      your_rating: @post.star_rating_for(current_user)&.to_f,
      **star_summary_json(@post)
    }
  end

  def render_star_update
    @post.reload
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "star-rating-post-#{@post.id}",
          partial: "star_ratings/star_rating",
          locals: { post: @post }
        )
      end
      format.html { redirect_to @post.discussion }
      format.json { render json: rating_json }
    end
  end
end
