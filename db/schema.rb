# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150315231956) do

  create_table "api_tokens", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "token_key",    limit: 255
    t.string   "token_secret", limit: 255
    t.datetime "expires_at"
    t.integer  "status",                   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_tokens", ["token_key"], name: "index_api_tokens_on_token_key", unique: true

  create_table "settings", force: :cascade do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true

  create_table "user_authentications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "uuid",                limit: 255
    t.string   "uid",                 limit: 255
    t.string   "provider",            limit: 255
    t.string   "name",                limit: 255
    t.string   "email",               limit: 255
    t.string   "username",            limit: 255
    t.string   "token",               limit: 255
    t.string   "secret",              limit: 255
    t.string   "refresh_token",       limit: 255
    t.datetime "token_expires_at"
    t.string   "avatar_file_name",    limit: 255
    t.string   "avatar_content_type", limit: 255
    t.integer  "avatar_file_size",                default: 0
    t.datetime "avatar_updated_at"
    t.string   "profile_url",         limit: 255
    t.string   "profile_image_url",   limit: 255
    t.date     "birthday"
    t.string   "locale",              limit: 255
    t.string   "gender",              limit: 255
    t.integer  "status",                          default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_authentications", ["uid", "provider"], name: "index_user_authentications_on_uid_and_provider"
  add_index "user_authentications", ["uuid"], name: "index_user_authentications_on_uuid", unique: true

  create_table "users", force: :cascade do |t|
    t.string   "uuid",                limit: 255,             null: false
    t.string   "slug",                limit: 255
    t.string   "name",                limit: 255,             null: false
    t.string   "email",               limit: 255
    t.string   "login",               limit: 255,             null: false
    t.string   "avatar_file_name",    limit: 255
    t.string   "avatar_content_type", limit: 255
    t.integer  "avatar_file_size",                default: 0
    t.datetime "avatar_updated_at"
    t.string   "crypted_password",    limit: 255
    t.string   "password_salt",       limit: 255
    t.string   "persistence_token",   limit: 255,             null: false
    t.string   "perishable_token",    limit: 255,             null: false
    t.string   "single_access_token", limit: 255,             null: false
    t.integer  "login_count",                     default: 0, null: false
    t.integer  "failed_login_count",              default: 0, null: false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip",    limit: 255
    t.string   "last_login_ip",       limit: 255
    t.string   "signup_method",       limit: 255
    t.integer  "roles_mask"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["last_request_at"], name: "index_users_on_last_request_at"
  add_index "users", ["login"], name: "index_users_on_login", unique: true
  add_index "users", ["perishable_token"], name: "index_users_on_perishable_token"
  add_index "users", ["persistence_token"], name: "index_users_on_persistence_token"
  add_index "users", ["single_access_token"], name: "index_users_on_single_access_token"
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true
  add_index "users", ["uuid"], name: "index_users_on_uuid", unique: true

  create_table "web_site_page_colors", force: :cascade do |t|
    t.integer  "web_site_page_id"
    t.string   "uuid",             limit: 255
    t.integer  "user_id"
    t.integer  "color_red"
    t.integer  "color_green"
    t.integer  "color_blue"
    t.string   "color_hex",        limit: 255
    t.datetime "created_at"
    t.integer  "palette_red"
    t.integer  "palette_green"
    t.integer  "palette_blue"
    t.string   "palette_hex",      limit: 255
  end

  add_index "web_site_page_colors", ["user_id"], name: "index_web_site_page_colors_on_user_id"
  add_index "web_site_page_colors", ["uuid"], name: "index_web_site_page_colors_on_uuid", unique: true

  create_table "web_site_pages", force: :cascade do |t|
    t.integer  "web_site_id"
    t.string   "uuid",             limit: 255
    t.string   "slug",             limit: 255
    t.text     "url"
    t.text     "uri_path"
    t.integer  "color_avg_red"
    t.integer  "color_avg_green"
    t.integer  "color_avg_blue"
    t.string   "color_avg_hex",    limit: 255
    t.integer  "colors_count",                 default: 0
    t.integer  "status",                       default: 0
    t.string   "color_avg_job_id", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "web_site_pages", ["slug"], name: "index_web_site_pages_on_slug", unique: true
  add_index "web_site_pages", ["uuid"], name: "index_web_site_pages_on_uuid", unique: true

  create_table "web_sites", force: :cascade do |t|
    t.string   "uuid",           limit: 255
    t.string   "slug",           limit: 255
    t.string   "uri_domain_tld", limit: 255
    t.text     "url"
    t.integer  "pages_count",                default: 0
    t.integer  "status",                     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "web_sites", ["slug"], name: "index_web_sites_on_slug", unique: true
  add_index "web_sites", ["uuid"], name: "index_web_sites_on_uuid", unique: true

end
