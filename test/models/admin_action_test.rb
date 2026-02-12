require "test_helper"

class AdminActionTest < ActiveSupport::TestCase
  test "valid admin action" do
    action = AdminAction.new(admin_user: users(:admin_user), action_type: "test_action")
    assert action.valid?
  end

  test "requires action_type" do
    action = AdminAction.new(admin_user: users(:admin_user))
    assert_not action.valid?
    assert_includes action.errors[:action_type], "can't be blank"
  end

  test "log! creates an action record" do
    assert_difference("AdminAction.count") do
      AdminAction.log!(
        admin_user: users(:admin_user),
        action_type: "test_action",
        details: "test details"
      )
    end
  end

  test "log! with target" do
    discussion = discussions(:one)
    action = AdminAction.log!(
      admin_user: users(:admin_user),
      action_type: "discussion_pin",
      target: discussion,
      details: "pinned"
    )
    assert_equal "Discussion", action.target_type
    assert_equal discussion.id, action.target_id
  end

  test "description for known action types" do
    action = AdminAction.new(action_type: "user_destroy", details: "testuser")
    assert_equal "Deleted user: testuser", action.description

    action = AdminAction.new(action_type: "discussion_pin", details: "A Thread")
    assert_equal "Pinned discussion: A Thread", action.description
  end

  test "recent scope orders by created_at desc" do
    actions = AdminAction.recent
    if actions.count > 1
      assert actions.first.created_at >= actions.last.created_at
    end
  end
end
