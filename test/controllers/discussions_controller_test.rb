require "test_helper"

class DiscussionsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    discussion = discussions(:one)
    get discussion_url(discussion)
    assert_response :success
  end

  test "should get new" do
    realm = realms(:the_writ)
    get new_realm_discussion_url(realm.slug)
    assert_response :success
  end

  test "should create discussion" do
    realm = realms(:the_writ)
    assert_difference("Discussion.count") do
      post realm_discussions_url(realm.slug), params: {
        discussion: {
          subject: "New Thread",
          content: "Thread body content here.",
          author_name: "Anonymous"
        },
        thread_type: "general"
      }
    end
    assert_redirected_to discussion_url(Discussion.last)
  end
end
