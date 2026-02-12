require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "should create post" do
    discussion = discussions(:one)
    assert_difference("Post.count") do
      post discussion_posts_url(discussion), params: {
        post: {
          content: "A new reply to the discussion.",
          author_name: "Anonymous"
        }
      }
    end
    assert_response :redirect
    assert_match %r{/discussions/#{discussion.id}}, response.location
  end
end
