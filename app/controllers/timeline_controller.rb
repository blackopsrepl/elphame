class TimelineController < ApplicationController
  def index
    @discussions = Discussion.includes(:labels).order(created_at: :desc).page(params[:page]).per(50)
    @realms = Realm.all.index_by(&:id) # For fast lookup
  end
end
