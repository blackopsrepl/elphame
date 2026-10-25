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

  test "an anonymous visitor cannot delete an anonymous post" do
    anonymous_post = posts(:one)
    assert_nil anonymous_post.user

    assert_no_difference("Post.count") do
      delete post_url(anonymous_post)
    end
  end

  test "an anonymous visitor cannot rewrite an anonymous post" do
    anonymous_post = posts(:one)

    patch post_url(anonymous_post), params: { post: { content: "Rewritten by a stranger" } }

    assert_not_equal "Rewritten by a stranger", anonymous_post.reload.content
  end
end
