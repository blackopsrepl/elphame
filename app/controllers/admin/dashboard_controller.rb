module Admin
  class DashboardController < Admin::ApplicationController
    def index
      @user_count = User.count
      @discussion_count = Discussion.count
      @post_count = Post.count
      @realm_count = Realm.count
      @label_count = Label.count
      @star_rating_count = StarRating.count

      respond_to do |format|
        format.html do
          @recent_users = User.order(created_at: :desc).limit(5)
          @recent_discussions = Discussion.includes(:realm).order(created_at: :desc).limit(10)
          @recent_actions = AdminAction.includes(:admin_user).recent.limit(10)
        end
        format.json do
          render json: {
            counts: {
              users: @user_count,
              discussions: @discussion_count,
              posts: @post_count,
              realms: @realm_count,
              labels: @label_count,
              star_ratings: @star_rating_count
            }
          }
        end
      end
    end
  end
end
