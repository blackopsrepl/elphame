module Admin
  class PostsController < Admin::ApplicationController
    def destroy
      post = requested_resource
      log_admin_action("post_destroy", target: post, details: "Post ##{post.id} in Discussion ##{post.discussion_id}")
      post.destroy
      redirect_to admin_posts_path, notice: "Post deleted."
    end
  end
end
