require "test_helper"

class LabelTest < ActiveSupport::TestCase
  test "valid label" do
    label = Label.new(name: "new-label", category: "status", emoji: "🏷️")
    assert label.valid?
  end

  test "requires name" do
    label = Label.new(category: "status")
    assert_not label.valid?
    assert_includes label.errors[:name], "can't be blank"
  end

  test "requires unique name" do
    label = Label.new(name: labels(:urgent).name, category: "status")
    assert_not label.valid?
  end

  test "requires valid category" do
    label = Label.new(name: "test-label", category: "invalid")
    assert_not label.valid?
  end

  test "valid categories" do
    %w[priority status type].each do |cat|
      label = Label.new(name: "test-#{cat}", category: cat)
      assert label.valid?, "Expected category '#{cat}' to be valid"
    end
  end

  test "display_name includes emoji and name" do
    label = labels(:urgent)
    assert_includes label.display_name, label.emoji
    assert_includes label.display_name, label.name.humanize
  end

  test "active scope" do
    active_labels = Label.active
    active_labels.each do |label|
      assert label.active?
    end
  end
end
