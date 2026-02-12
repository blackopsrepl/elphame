module Admin
  class DashboardController < Admin::ApplicationController
    def index
      @user_count = User.count
      @discussion_count = Discussion.count
      @post_count = Post.count
      @realm_count = Realm.count
      @label_count = Label.count
      @star_rating_count = StarRating.count

      @recent_users = User.order(created_at: :desc).limit(5)
      @recent_discussions = Discussion.includes(:realm).order(created_at: :desc).limit(10)
      @recent_actions = AdminAction.includes(:admin_user).recent.limit(10)
    end
  end
end
