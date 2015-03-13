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

ActiveRecord::Schema.define(version: 20150210033221) do

  create_table "api_tokens", force: true do |t|
    t.integer  "user_id"
    t.string   "token_key"
    t.string   "token_secret"
    t.datetime "expires_at"
    t.integer  "status",       default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_tokens", ["token_key"], name: "index_api_tokens_on_token_key", unique: true

  create_table "user_authentications", force: true do |t|
    t.integer  "user_id"
    t.string   "uuid"
    t.string   "uid"
    t.string   "provider"
    t.string   "name"
    t.string   "email"
    t.string   "username"
    t.string   "token"
    t.string   "secret"
    t.string   "refresh_token"
    t.datetime "token_expires_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size",    default: 0
    t.datetime "avatar_updated_at"
    t.string   "profile_url"
    t.string   "profile_image_url"
    t.date     "birthday"
    t.string   "locale"
    t.string   "gender"
    t.integer  "status",              default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_authentications", ["uid", "provider"], name: "index_user_authentications_on_uid_and_provider"
  add_index "user_authentications", ["uuid"], name: "index_user_authentications_on_uuid", unique: true

  create_table "users", force: true do |t|
    t.string   "uuid",                            null: false
    t.string   "slug"
    t.string   "name",                            null: false
    t.string   "email"
    t.string   "login",                           null: false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size",    default: 0
    t.datetime "avatar_updated_at"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token",               null: false
    t.string   "perishable_token",                null: false
    t.string   "single_access_token",             null: false
    t.integer  "login_count",         default: 0, null: false
    t.integer  "failed_login_count",  default: 0, null: false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.string   "signup_method"
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

  create_table "web_site_page_colors", force: true do |t|
    t.integer  "web_site_page_id"
    t.string   "uuid"
    t.integer  "user_id"
    t.integer  "color_red"
    t.integer  "color_green"
    t.integer  "color_blue"
    t.integer  "color_hex"
    t.datetime "created_at"
  end

  add_index "web_site_page_colors", ["user_id"], name: "index_web_site_page_colors_on_user_id"
  add_index "web_site_page_colors", ["uuid"], name: "index_web_site_page_colors_on_uuid", unique: true

  create_table "web_site_pages", force: true do |t|
    t.integer  "web_site_id"
    t.string   "uuid"
    t.string   "slug"
    t.text     "url"
    t.text     "uri_path"
    t.integer  "color_avg_red"
    t.integer  "color_avg_green"
    t.integer  "color_avg_blue"
    t.string   "color_avg_hex"
    t.integer  "colors_count",     default: 0
    t.integer  "status",           default: 0
    t.string   "color_avg_job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "web_site_pages", ["slug"], name: "index_web_site_pages_on_slug", unique: true
  add_index "web_site_pages", ["uuid"], name: "index_web_site_pages_on_uuid", unique: true

  create_table "web_sites", force: true do |t|
    t.string   "uuid"
    t.string   "slug"
    t.string   "uri_domain_tld"
    t.text     "url"
    t.integer  "pages_count",    default: 0
    t.integer  "status",         default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "web_sites", ["slug"], name: "index_web_sites_on_slug", unique: true
  add_index "web_sites", ["uuid"], name: "index_web_sites_on_uuid", unique: true

end
