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

ActiveRecord::Schema[7.0].define(version: 2024_06_14_191702) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "circle_members", force: :cascade do |t|
    t.bigint "circle_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["circle_id"], name: "index_circle_members_on_circle_id"
    t.index ["user_id"], name: "index_circle_members_on_user_id"
  end

  create_table "circles", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.string "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_circles_on_user_id"
  end

  create_table "comment_user_reactions", force: :cascade do |t|
    t.bigint "comment_id", null: false
    t.integer "user_id", null: false
    t.integer "reaction_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_comment_user_reactions_on_comment_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.integer "parent_comment_id"
    t.integer "author_id", null: false
    t.string "comment_text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_comments_on_post_id"
  end

  create_table "contents", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.string "video_url"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_contents_on_post_id"
  end

  create_table "post_user_reactions", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.integer "user_id", null: false
    t.integer "reaction_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_post_user_reactions_on_post_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "circle_id", null: false
    t.string "caption"
    t.integer "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["circle_id"], name: "index_posts_on_circle_id"
  end

  create_table "reactions", force: :cascade do |t|
    t.string "image_url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "display_name", null: false
    t.integer "notification_frequency", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "circle_members", "circles"
  add_foreign_key "circle_members", "users"
  add_foreign_key "circles", "users"
  add_foreign_key "comment_user_reactions", "comments"
  add_foreign_key "comments", "posts"
  add_foreign_key "contents", "posts"
  add_foreign_key "post_user_reactions", "posts"
  add_foreign_key "posts", "circles"
end
