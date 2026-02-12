module Api
  class UsersController < ApplicationController
    skip_before_action :verify_authenticity_token

      def index
      users = User.order(username: :asc)
                  .limit(50)
                  .select(:id, :username)

      users_data = users.map do |user|
        {
          id: user.id,
          username: user.username,
          avatar_url: user.avatar.attached? ? url_for(user.avatar_thumbnail) : nil
        }
      end

      render json: { users: users_data }
    end
  end
end
