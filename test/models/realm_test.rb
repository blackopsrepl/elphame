require "test_helper"

class RealmTest < ActiveSupport::TestCase
  test "valid realm" do
    realm = Realm.new(name: "Test Realm", slug: "test-realm", description: "A test realm")
    assert realm.valid?
  end

  test "requires name" do
    realm = Realm.new(slug: "no-name")
    assert_not realm.valid?
    assert_includes realm.errors[:name], "can't be blank"
  end

  test "requires unique name" do
    realm = Realm.new(name: realms(:the_writ).name, slug: "unique-slug")
    assert_not realm.valid?
    assert_includes realm.errors[:name], "has already been taken"
  end

  test "requires unique slug" do
    realm = Realm.new(name: "Unique Name", slug: realms(:the_writ).slug)
    assert_not realm.valid?
    assert_includes realm.errors[:slug], "has already been taken"
  end

  test "auto-generates slug from name" do
    realm = Realm.new(name: "My New Realm")
    realm.valid?
    assert_equal "my-new-realm", realm.slug
  end

  test "validates color format" do
    realm = realms(:the_writ)
    realm.color = "not-a-color"
    assert_not realm.valid?

    realm.color = "#ff00ff"
    assert realm.valid?
  end

  test "thread_count returns discussions_count" do
    realm = realms(:the_writ)
    assert_equal realm.discussions_count, realm.thread_count
  end

  test "has_one_attached banner_image" do
    realm = realms(:the_writ)
    assert_respond_to realm, :banner_image
  end
end
