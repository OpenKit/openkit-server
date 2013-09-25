class CreateSandboxSessionsAndTokens < ActiveRecord::Migration
  def up
    create_table "sandbox_client_sessions", :force => true do |t|
      t.string   "uuid"
      t.string   "fb_id"
      t.string   "google_id"
      t.string   "custom_id"
      t.string   "ok_id"
      t.string   "push_token"
      t.string   "client_db_version"
      t.datetime "client_created_at"
      t.datetime "created_at",        :null => false
      t.datetime "updated_at",        :null => false
      t.integer  "app_id"
    end

    create_table "sandbox_tokens", :force => true do |t|
      t.integer  "user_id"
      t.integer  "app_id"
      t.string   "apns_token"
      t.datetime "created_at", :null => false
    end
    add_index "sandbox_tokens", ["user_id", "app_id"]
  end

  def down
    remove_index "sandbox_tokens", :column => ["user_id", "app_id"]
    drop_table "sandbox_tokens"
    drop_table "sandbox_client_sessions"
  end
end
