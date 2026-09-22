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

ActiveRecord::Schema[8.1].define(version: 2026_09_22_200100) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "comment_likes", force: :cascade do |t|
    t.bigint "comment_id", null: false
    t.datetime "created_at", null: false
    t.string "device_id", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id", "device_id"], name: "index_comment_likes_on_comment_id_and_device_id", unique: true
    t.index ["comment_id"], name: "index_comment_likes_on_comment_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.string "device_id", null: false
    t.string "media_type", null: false
    t.bigint "parent_id"
    t.bigint "title_id", null: false
    t.datetime "updated_at", null: false
    t.string "user_name", null: false
    t.index ["media_type", "title_id", "created_at"], name: "index_comments_on_media_type_and_title_id_and_created_at"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
  end

  create_table "guest_users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "device_id", null: false
    t.string "display_name", default: "Гость", null: false
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_guest_users_on_device_id", unique: true
  end

  create_table "library_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "device_id", null: false
    t.boolean "favorite", default: false, null: false
    t.string "media_type", null: false
    t.text "personal_note", default: "", null: false
    t.string "status"
    t.bigint "title_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_rating"
    t.index ["device_id", "media_type", "title_id"], name: "index_library_entries_on_owner_and_title", unique: true
  end

  create_table "recent_views", force: :cascade do |t|
    t.string "device_id", null: false
    t.string "media_type", null: false
    t.bigint "title_id", null: false
    t.datetime "viewed_at", null: false
    t.index ["device_id", "media_type", "title_id"], name: "index_recent_views_on_device_id_and_media_type_and_title_id", unique: true
    t.index ["device_id", "viewed_at"], name: "index_recent_views_on_device_id_and_viewed_at"
  end

  add_foreign_key "comment_likes", "comments"
  add_foreign_key "comments", "comments", column: "parent_id"
end
