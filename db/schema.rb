# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_12_160046) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_actions", force: :cascade do |t|
    t.string "action_type", null: false
    t.integer "admin_user_id", null: false
    t.datetime "created_at", null: false
    t.text "details"
    t.integer "target_id"
    t.string "target_type"
    t.datetime "updated_at", null: false
    t.index ["action_type"], name: "index_admin_actions_on_action_type"
    t.index ["admin_user_id"], name: "index_admin_actions_on_admin_user_id"
    t.index ["created_at"], name: "index_admin_actions_on_created_at"
    t.index ["target_type", "target_id"], name: "index_admin_actions_on_target_type_and_target_id"
  end

  create_table "discussions", force: :cascade do |t|
    t.string "author_name"
    t.text "content"
    t.datetime "created_at", null: false
    t.string "image"
    t.datetime "last_activity_at"
    t.integer "manual_boost_score", default: 0
    t.boolean "pinned", default: false, null: false
    t.datetime "pinned_at"
    t.integer "pinned_by_user_id"
    t.integer "realm_id", null: false
    t.integer "reply_count_cache", default: 0
    t.string "soft_username"
    t.string "subject"
    t.decimal "total_stars", precision: 10, scale: 1, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["last_activity_at"], name: "index_discussions_on_last_activity_at"
    t.index ["pinned"], name: "index_discussions_on_pinned"
    t.index ["realm_id"], name: "index_discussions_on_realm_id"
    t.index ["soft_username"], name: "index_discussions_on_soft_username"
    t.index ["user_id"], name: "index_discussions_on_user_id"
  end

  create_table "labels", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.string "emoji"
    t.string "name", null: false
    t.integer "position", default: 0
    t.integer "sort_weight", default: 0
    t.datetime "updated_at", null: false
    t.boolean "user_selectable", default: false, null: false
    t.index ["active"], name: "index_labels_on_active"
    t.index ["category", "position"], name: "index_labels_on_category_and_position"
  end

  create_table "posts", force: :cascade do |t|
    t.string "author_name"
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "discussion_id", null: false
    t.string "image"
    t.integer "quoted_post_id"
    t.string "soft_username"
    t.integer "star_count_cache", default: 0, null: false
    t.decimal "star_total_cache", precision: 8, scale: 1, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["discussion_id"], name: "index_posts_on_discussion_id"
    t.index ["quoted_post_id"], name: "index_posts_on_quoted_post_id"
    t.index ["soft_username"], name: "index_posts_on_soft_username"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "realms", force: :cascade do |t|
    t.string "color", default: "#7e22ce"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "discussions_count", default: 0, null: false
    t.string "icon", default: ""
    t.string "name"
    t.integer "position", default: 99
    t.text "rules", default: ""
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_realms_on_name", unique: true
    t.index ["slug"], name: "index_realms_on_slug", unique: true
  end

  create_table "star_ratings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "post_id", null: false
    t.decimal "rating", precision: 2, scale: 1, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["post_id", "user_id"], name: "idx_star_ratings_post_user", unique: true
    t.index ["post_id"], name: "index_star_ratings_on_post_id"
    t.index ["user_id"], name: "index_star_ratings_on_user_id"
  end

  create_table "thread_labels", force: :cascade do |t|
    t.datetime "applied_at", null: false
    t.integer "applied_by_user_id"
    t.datetime "created_at", null: false
    t.integer "discussion_id", null: false
    t.integer "label_id", null: false
    t.datetime "updated_at", null: false
    t.index ["applied_at"], name: "index_thread_labels_on_applied_at"
    t.index ["applied_by_user_id"], name: "index_thread_labels_on_applied_by_user_id"
    t.index ["discussion_id", "label_id"], name: "index_thread_labels_on_discussion_id_and_label_id", unique: true
    t.index ["discussion_id"], name: "index_thread_labels_on_discussion_id"
    t.index ["label_id"], name: "index_thread_labels_on_label_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false
    t.string "bot_token"
    t.datetime "created_at", null: false
    t.string "email", default: ""
    t.string "encrypted_password", default: ""
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["bot_token"], name: "index_users_on_bot_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "webhooks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_webhooks_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "admin_actions", "users", column: "admin_user_id"
  add_foreign_key "discussions", "realms"
  add_foreign_key "discussions", "users"
  add_foreign_key "discussions", "users", column: "pinned_by_user_id"
  add_foreign_key "posts", "discussions"
  add_foreign_key "posts", "posts", column: "quoted_post_id"
  add_foreign_key "posts", "users"
  add_foreign_key "star_ratings", "posts"
  add_foreign_key "star_ratings", "users"
  add_foreign_key "thread_labels", "discussions"
  add_foreign_key "thread_labels", "labels"
  add_foreign_key "thread_labels", "users", column: "applied_by_user_id"
  add_foreign_key "webhooks", "users"
end
