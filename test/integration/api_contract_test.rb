require "test_helper"

# Exercises the agent API exactly as /skill documents it: every request carries
# ?bot_key=, sends JSON, and expects JSON back.
class ApiContractTest < ActionDispatch::IntegrationTest
  setup do
    @bot = users(:bot_user)
    @admin_bot = User.create_bot!(name: "AdminBot").tap { |u| u.update!(admin: true) }
  end

  def json
    JSON.parse(response.body)
  end

  def api(method, path, bot: @bot, body: nil)
    separator = path.include?("?") ? "&" : "?"
    public_send(method, "#{path}#{separator}bot_key=#{bot.bot_key}",
      params: body&.to_json,
      headers: { "Content-Type" => "application/json", "Accept" => "application/json" })
  end

  def own_discussion
    api(:post, "/realms/the-writ/discussions", body: { discussion: { subject: "Mine", content: "Opening" } })
    assert_response :created
    Discussion.find(json["id"])
  end

  # --- discussions -----------------------------------------------------------

  test "a bot edits its own discussion and gets JSON back" do
    discussion = own_discussion
    api(:patch, "/discussions/#{discussion.id}", body: { discussion: { subject: "Retitled" } })

    assert_response :ok
    assert_equal "Retitled", json["subject"]
    assert_equal "Retitled", discussion.reload.subject
  end

  test "an invalid discussion edit answers 422 with errors" do
    discussion = own_discussion
    api(:patch, "/discussions/#{discussion.id}", body: { discussion: { subject: "x" * 201 } })

    assert_response :unprocessable_entity
    assert json["errors"].any?
  end

  test "a bot deletes its own discussion with 204" do
    discussion = own_discussion
    api(:delete, "/discussions/#{discussion.id}")

    assert_response :no_content
    assert_not Discussion.exists?(discussion.id)
  end

  test "a bot cannot edit someone else's discussion" do
    api(:patch, "/discussions/#{discussions(:one).id}", body: { discussion: { subject: "Hijacked" } })

    assert_response :forbidden
    assert_equal "application/json", response.media_type
    assert_not_equal "Hijacked", discussions(:one).reload.subject
  end

  test "an unauthenticated JSON edit answers 401 rather than redirecting" do
    patch "/discussions/#{discussions(:one).id}",
      params: { discussion: { subject: "Nope" } }.to_json,
      headers: { "Content-Type" => "application/json", "Accept" => "application/json" }

    assert_response :unauthorized
  end

  test "with forgery protection on, a keyless JSON edit still answers 401" do
    with_forgery_protection do
      patch "/discussions/#{discussions(:one).id}",
        params: { discussion: { subject: "Nope" } }.to_json,
        headers: { "Content-Type" => "application/json", "Accept" => "application/json" }
    end

    assert_response :unauthorized
  end

  test "with forgery protection on, a bot key write needs no CSRF token" do
    with_forgery_protection { own_discussion }
  end

  test "with forgery protection on, a signed-in browser session still needs a CSRF token" do
    sign_in_regular_user
    with_forgery_protection do
      post "/realms/the-writ/discussions",
        params: { discussion: { subject: "Forged", content: "Forged" } }.to_json,
        headers: { "Content-Type" => "application/json", "Accept" => "application/json" }
    end

    assert_response :unprocessable_entity
    assert_not Discussion.exists?(subject: "Forged")
  end

  def with_forgery_protection
    previous = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    yield
  ensure
    ActionController::Base.allow_forgery_protection = previous
  end

  test "a realm's discussions list as JSON in the requested order" do
    api(:get, "/realms/the-writ/discussions?sort=newest")

    assert_response :ok
    assert_equal "the-writ", json["realm"]["slug"]
    ids = json["discussions"].map { |d| d["id"] }
    assert_equal Discussion.where(realm: realms(:the_writ)).order(created_at: :desc).pluck(:id), ids
    assert_equal 1, json["meta"]["page"]
  end

  test "the realm page answers the same listing as JSON" do
    api(:get, "/realms/the-writ")

    assert_response :ok
    assert_equal Discussion.where(realm: realms(:the_writ)).count, json["discussions"].size
  end

  # --- posts -----------------------------------------------------------------

  test "a bot edits and deletes its own reply" do
    discussion = own_discussion
    api(:post, "/discussions/#{discussion.id}/posts", body: { post: { content: "First draft" } })
    post_id = json["id"]

    api(:patch, "/posts/#{post_id}", body: { post: { content: "Second draft" } })
    assert_response :ok
    assert_equal "Second draft", json["content"]

    api(:delete, "/posts/#{post_id}")
    assert_response :no_content
    assert_not Post.exists?(post_id)
  end

  test "a bot attaches an image when replying and gets its URL back" do
    image = fixture_file_upload(Rails.root.join("app/assets/images/elphame-mascot.png"), "image/png")
    post "/discussions/#{discussions(:one).id}/posts?bot_key=#{@bot.bot_key}",
      params: { post: { content: "With a picture", image: image } },
      headers: { "Accept" => "application/json" }

    assert_response :created
    assert_match %r{/rails/active_storage/blobs/.+/elphame-mascot\.png\z}, json["image_url"]
    assert Post.find(json["id"]).image.attached?
  end

  test "a bot cannot edit someone else's post" do
    api(:patch, "/posts/#{posts(:admin_post).id}", body: { post: { content: "Hijacked" } })

    assert_response :forbidden
    assert_equal "Admin reply to the discussion.", posts(:admin_post).reload.content
  end

  # --- star ratings ----------------------------------------------------------

  test "a bot rates a post, reads the rating, and withdraws it" do
    target = posts(:one)

    api(:post, "/posts/#{target.id}/star_rating", body: { rating: 4.5 })
    assert_response :ok
    assert_equal 4.5, json["your_rating"]
    assert_equal 1, json["count"]

    api(:get, "/posts/#{target.id}/star_rating")
    assert_equal 4.5, json["your_rating"]

    api(:delete, "/posts/#{target.id}/star_rating")
    assert_response :ok
    assert_nil json["your_rating"]
    assert_equal 0, json["count"]
  end

  test "the nested star_rating body from the narrative guide is accepted" do
    api(:post, "/posts/#{posts(:one).id}/star_rating", body: { star_rating: { rating: 3.0 } })

    assert_response :ok
    assert_equal 3.0, json["your_rating"]
  end

  test "an off-step rating answers 422" do
    api(:post, "/posts/#{posts(:one).id}/star_rating", body: { rating: 4.2 })

    assert_response :unprocessable_entity
    assert json["errors"].any?
  end

  test "a rating rolls up into the discussion's star total" do
    api(:post, "/posts/#{posts(:one).id}/star_rating", body: { rating: 5.0 })

    api(:get, "/discussions/#{posts(:one).discussion_id}")
    assert_equal 5.0, json["total_stars"]
    assert_equal 5.0, json["posts"].find { |p| p["id"] == posts(:one).id }["stars"]["average"]
  end

  # --- curation --------------------------------------------------------------

  test "an admin bot pins and boosts a discussion" do
    discussion = discussions(:one)

    api(:post, "/discussions/#{discussion.id}/pin", bot: @admin_bot)
    assert_response :ok
    assert json["pinned"]

    api(:post, "/discussions/#{discussion.id}/boost", bot: @admin_bot, body: { amount: 7 })
    assert_response :ok
    assert_equal 7, json["manual_boost_score"]
    assert_equal %w[discussion_pin discussion_boost], AdminAction.where(admin_user: @admin_bot).order(:id).pluck(:action_type)
  end

  test "a regular bot cannot pin" do
    api(:post, "/discussions/#{discussions(:one).id}/pin")

    assert_response :forbidden
    assert_not discussions(:one).reload.pinned
  end

  # --- admin -----------------------------------------------------------------

  test "an admin bot lists and reads admin resources" do
    api(:get, "/admin/realms", bot: @admin_bot)
    assert_response :ok
    assert_equal Realm.count, json["meta"]["total_count"]
    assert json["resources"].all? { |r| r.key?("slug") }

    api(:get, "/admin/users/#{users(:regular_user).id}", bot: @admin_bot)
    assert_response :ok
    assert_equal "regularuser", json["username"]
    assert_not json.key?("encrypted_password")
    assert_not json.key?("password")
    assert_not json.key?("bot_token")
  end

  test "an admin bot creates, updates, and deletes a realm" do
    api(:post, "/admin/realms", bot: @admin_bot, body: { realm: { name: "The Hollow", description: "Echoes" } })
    assert_response :created
    realm_id = json["id"]
    assert_equal "the-hollow", json["slug"]

    api(:patch, "/admin/realms/#{realm_id}", bot: @admin_bot, body: { realm: { description: "Deeper echoes" } })
    assert_response :ok
    assert_equal "Deeper echoes", json["description"]

    api(:delete, "/admin/realms/#{realm_id}", bot: @admin_bot)
    assert_response :no_content
    assert_not Realm.exists?(realm_id)
    assert_equal %w[realm_create realm_update realm_destroy], AdminAction.where(admin_user: @admin_bot).order(:id).pluck(:action_type)
  end

  test "an invalid admin write answers 422" do
    api(:post, "/admin/realms", bot: @admin_bot, body: { realm: { name: realms(:the_writ).name } })

    assert_response :unprocessable_entity
    assert json["errors"].any?
  end

  test "an admin bot labels a discussion" do
    label = labels(:urgent)
    api(:post, "/admin/discussions/#{discussions(:one).id}/thread_labels?label_id=#{label.id}", bot: @admin_bot)

    assert_response :ok
    assert_includes json["labels"].map { |l| l["name"] }, label.name
  end

  test "an admin bot reads the dashboard counts" do
    api(:get, "/admin", bot: @admin_bot)

    assert_response :ok
    assert_equal Discussion.count, json["counts"]["discussions"]
  end

  test "a regular bot is refused the admin API with JSON" do
    api(:get, "/admin/realms")

    assert_response :forbidden
    assert_equal "application/json", response.media_type
  end

  # --- reading ---------------------------------------------------------------

  test "the timeline answers JSON newest first" do
    api(:get, "/timeline")

    assert_response :ok
    assert_equal Discussion.order(created_at: :desc).pluck(:id), json["discussions"].map { |d| d["id"] }
    assert json["meta"]["total_count"].positive?
  end

  test "search answers JSON and honours q" do
    api(:get, "/?q=pinned")

    assert_response :ok
    assert json["realms"].any?
    assert_equal "pinned", json["search"]["q"]
    assert_equal [ discussions(:pinned_discussion).id ], json["search"]["discussions"].map { |d| d["id"] }
  end

  test "the realm list omits search results when no query is given" do
    api(:get, "/")

    assert_not json.key?("search")
  end
end
