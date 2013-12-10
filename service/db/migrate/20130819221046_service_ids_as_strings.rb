class ServiceIdsAsStrings < ActiveRecord::Migration
  def up
    remove_index "users", :name => "index_users_on_custom_id"
    remove_index "users", :name => "index_users_on_fb_id"
    remove_index "users", :name => "index_users_on_gamecenter_id"
    remove_index "users", :name => "index_users_on_google_id"
    remove_index "users", :name => "index_users_on_twitter_id"

    change_column :users, :custom_id,     :string, :limit => 40
    change_column :users, :fb_id,         :string, :limit => 40
    change_column :users, :gamecenter_id, :string, :limit => 40
    change_column :users, :google_id,     :string, :limit => 40
    change_column :users, :twitter_id,    :string, :limit => 40

    add_index "users", ["custom_id"],     :name => "index_users_on_custom_id"
    add_index "users", ["fb_id"],         :name => "index_users_on_fb_id"
    add_index "users", ["gamecenter_id"], :name => "index_users_on_gamecenter_id"
    add_index "users", ["google_id"],     :name => "index_users_on_google_id"
    add_index "users", ["twitter_id"],    :name => "index_users_on_twitter_id"
  end

  def down
    remove_index "users", :name => "index_users_on_twitter_id"
    remove_index "users", :name => "index_users_on_google_id"
    remove_index "users", :name => "index_users_on_gamecenter_id"
    remove_index "users", :name => "index_users_on_fb_id"
    remove_index "users", :name => "index_users_on_custom_id"

    change_column :users, :twitter_id,            :integer, :limit => 8
    change_column :users, :google_id,             :integer, :limit => 8
    change_column :users, :gamecenter_id,         :string
    change_column :users, :fb_id,                 :integer, :limit => 8
    change_column :users, :custom_id,             :integer, :limit => 8

    add_index "users", ["custom_id"],     :name => "index_users_on_custom_id"
    add_index "users", ["fb_id"],         :name => "index_users_on_fb_id"
    add_index "users", ["gamecenter_id"], :name => "index_users_on_gamecenter_id"
    add_index "users", ["google_id"],     :name => "index_users_on_google_id"
    add_index "users", ["twitter_id"],    :name => "index_users_on_twitter_id"
  end
end
