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
      ).includes(:realm, :labels).with_attached_image.order(created_at: :desc).page(params[:page]).per(25)
    end

    respond_to do |format|
      format.html
      format.json do
        body = {
          realms: @realms.map { |r|
            { id: r.id, name: r.name, slug: r.slug, description: r.description, discussions_count: r.discussions_count }
          }
        }
        if @search_results
          body[:search] = {
            q: params[:q],
            discussions: @search_results.map { |d| discussion_json(d) },
            meta: page_meta_json(@search_results)
          }
        end
        render json: body
      end
    end
  end

  def show
    @realm = Realm.find_by!(slug: params[:slug])
    @discussions = @realm.discussions.listed(sort: params[:sort], label: params[:label])
                         .includes(:labels, :user).with_attached_image.page(params[:page]).per(25)

    respond_to do |format|
      format.html { @labels = Label.active.order(:category, :position) }
      format.json { render json: discussions_listing_json(@realm, @discussions) }
    end
  end
end
