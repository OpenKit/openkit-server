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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130826194151) do

  create_table "achievement_scores", :force => true do |t|
    t.integer  "user_id"
    t.integer  "achievement_id"
    t.integer  "progress"
    t.datetime "created_at",     :null => false
  end

  add_index "achievement_scores", ["user_id", "achievement_id"], :name => "index_achievement_progress_on_app_user_and_achievement_id"
  add_index "achievement_scores", ["user_id"], :name => "index_achievement_progress_on_app_and_user_id"

  create_table "achievements", :force => true do |t|
    t.string   "name"
    t.integer  "app_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "icon_locked_file_name"
    t.string   "icon_locked_content_type"
    t.integer  "icon_locked_file_size"
    t.datetime "icon_locked_updated_at"
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.boolean  "in_development",           :default => true
    t.text     "desc"
    t.integer  "points"
    t.integer  "goal"
  end

  add_index "achievements", ["app_id"], :name => "index_achievements_on_app_id"

  create_table "apps", :force => true do |t|
    t.string   "name"
    t.integer  "developer_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "slug"
    t.string   "app_key",           :limit => 20
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.string   "fbid"
    t.string   "secret_key",        :limit => 40
  end

  add_index "apps", ["app_key"], :name => "index_apps_on_app_key", :unique => true
  add_index "apps", ["developer_id", "slug"], :name => "index_apps_on_developer_id_and_slug"
  add_index "apps", ["developer_id"], :name => "index_apps_on_developer_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "developers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.string   "perishable_token",  :default => "", :null => false
  end

  add_index "developers", ["perishable_token"], :name => "index_developers_on_perishable_token"

  create_table "leaderboards", :force => true do |t|
    t.string   "name"
    t.integer  "app_id"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.boolean  "in_development",                  :default => true
    t.string   "sort_type",         :limit => 20
    t.string   "gamecenter_id"
    t.string   "gpg_id"
    t.integer  "priority",                        :default => 100,  :null => false
  end

  add_index "leaderboards", ["app_id"], :name => "index_leaderboards_on_game_id"

  create_table "oauth_nonces", :force => true do |t|
    t.string   "nonce"
    t.integer  "timestamp"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "oauth_nonces", ["nonce", "timestamp"], :name => "index_oauth_nonces_on_nonce_and_timestamp", :unique => true

  create_table "scores", :force => true do |t|
    t.integer  "sort_value",     :limit => 8, :null => false
    t.integer  "user_id"
    t.integer  "leaderboard_id"
    t.datetime "created_at",                  :null => false
    t.string   "display_string"
    t.integer  "metadata"
  end

  add_index "scores", ["leaderboard_id", "sort_value", "created_at"], :name => "index_scores_composite_1"
  add_index "scores", ["leaderboard_id", "user_id", "sort_value", "created_at"], :name => "index_scores_composite_2"

  create_table "subscriptions", :force => true do |t|
    t.integer  "app_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "subscriptions", ["app_id"], :name => "index_subscriptions_on_app_id"
  add_index "subscriptions", ["user_id"], :name => "index_subscriptions_on_user_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "nick"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "developer_id"
    t.string   "twitter_id",    :limit => 40
    t.string   "fb_id",         :limit => 40
    t.string   "custom_id",     :limit => 40
    t.string   "google_id",     :limit => 40
    t.string   "gamecenter_id", :limit => 40
  end

  add_index "users", ["custom_id"], :name => "index_users_on_custom_id"
  add_index "users", ["developer_id"], :name => "index_users_on_developer_id"
  add_index "users", ["fb_id"], :name => "index_users_on_fb_id"
  add_index "users", ["gamecenter_id"], :name => "index_users_on_gamecenter_id"
  add_index "users", ["google_id"], :name => "index_users_on_google_id"
  add_index "users", ["twitter_id"], :name => "index_users_on_twitter_id"

end
