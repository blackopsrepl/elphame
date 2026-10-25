class TimelineController < ApplicationController
  def index
    @discussions = Discussion.includes(:labels, :realm).with_attached_image.order(created_at: :desc).page(params[:page]).per(50)

    respond_to do |format|
      format.html { @realms = Realm.all.index_by(&:id) } # For fast lookup
      format.json do
        render json: {
          discussions: @discussions.map { |d| discussion_json(d) },
          meta: page_meta_json(@discussions)
        }
      end
    end
  end
end
