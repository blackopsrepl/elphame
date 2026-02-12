require "test_helper"

class DiscussionTest < ActiveSupport::TestCase
  test "valid discussion" do
    discussion = Discussion.new(
      realm: realms(:the_writ),
      subject: "Test",
      content: "Test content"
    )
    assert discussion.valid?
  end

  test "requires content" do
    discussion = Discussion.new(realm: realms(:the_writ))
    assert_not discussion.valid?
    assert_includes discussion.errors[:content], "can't be blank"
  end

  test "content max length 5000" do
    discussion = Discussion.new(realm: realms(:the_writ), content: "a" * 5001)
    assert_not discussion.valid?
  end

  test "display_name returns username when user present" do
    discussion = discussions(:pinned_discussion)
    assert_equal users(:admin_user).username, discussion.display_name
  end

  test "display_name returns Anonymous when no user info" do
    discussion = discussions(:one)
    assert_equal "Anonymous", discussion.display_name
  end

  test "pin! sets pinned state" do
    discussion = discussions(:one)
    discussion.pin!(users(:admin_user))
    assert discussion.pinned?
    assert_not_nil discussion.pinned_at
    assert_equal users(:admin_user), discussion.pinned_by_user
  end

  test "unpin! clears pinned state" do
    discussion = discussions(:pinned_discussion)
    discussion.unpin!
    assert_not discussion.pinned?
    assert_nil discussion.pinned_at
  end

  test "update_total_stars! computes sum of post star caches" do
    discussion = discussions(:two)
    discussion.update_total_stars!
    expected = discussion.posts.sum(:star_total_cache)
    assert_equal expected, discussion.total_stars
  end

  test "average_stars returns weighted average" do
    discussion = discussions(:two)
    discussion.update_total_stars!
    count = discussion.total_star_ratings_count
    if count > 0
      expected = (discussion.total_stars / count.to_f).round(1)
      assert_equal expected, discussion.average_stars
    else
      assert_equal 0.0, discussion.average_stars
    end
  end

  test "activity_score includes pin weight" do
    discussion = discussions(:pinned_discussion)
    discussion.update_column(:last_activity_at, Time.current)
    score = discussion.activity_score
    assert score >= ActivityScoring::SCORE_PIN_WEIGHT - 1, "Expected score #{score} to be near #{ActivityScoring::SCORE_PIN_WEIGHT}"
  end

  test "activity_score excludes pin weight for unpinned" do
    discussion = discussions(:one)
    score = discussion.activity_score
    assert score < ActivityScoring::SCORE_PIN_WEIGHT
  end

  test "add_label and has_label?" do
    discussion = discussions(:two)
    label = labels(:bug)
    discussion.add_label(label.name, user: users(:admin_user))
    assert discussion.has_label?("bug")
  end

  test "remove_label" do
    discussion = discussions(:one)
    assert discussion.has_label?("urgent")
    discussion.remove_label("urgent")
    assert_not discussion.has_label?("urgent")
  end

  test "touch_activity! updates last_activity_at" do
    discussion = discussions(:one)
    old_time = discussion.last_activity_at
    discussion.touch_activity!
    assert discussion.reload.last_activity_at >= old_time
  end

  test "set_thread_type assigns type label" do
    discussion = discussions(:one)
    discussion.set_thread_type("question")
    assert discussion.has_label?("question")
  end

  test "set_thread_type replaces existing type label" do
    discussion = discussions(:one)
    discussion.set_thread_type("question")
    discussion.set_thread_type("technical")
    assert discussion.has_label?("technical")
    assert_not discussion.has_label?("question")
  end

  test "thread_type_name returns label display name" do
    discussion = discussions(:one)
    discussion.set_thread_type("question")
    assert_match(/question/i, discussion.thread_type_name)
  end
end
