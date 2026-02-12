class RealmsController < ApplicationController
  def index
    @realms = Realm.all.order(:position, :name)
    @realm_post_counts = Post.joins(:discussion).group("discussions.realm_id").count

    # Global search across realms
    if params[:q].present?
      @search_results = Discussion.where(
        "subject LIKE ? OR content LIKE ?",
        "%#{params[:q]}%",
        "%#{params[:q]}%"
      ).order(created_at: :desc).page(params[:page]).per(25)
    end

    respond_to do |format|
      format.html
      format.json do
        render json: {
          realms: @realms.map { |r|
            { id: r.id, name: r.name, slug: r.slug, description: r.description, discussions_count: r.discussions_count }
          }
        }
      end
    end
  end

  def show
    @realm = Realm.find_by!(slug: params[:slug])
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

    @discussions = @discussions.includes(:labels, :user).page(params[:page]).per(25)
    @labels = Label.active.order(:category, :position)
  end
end
