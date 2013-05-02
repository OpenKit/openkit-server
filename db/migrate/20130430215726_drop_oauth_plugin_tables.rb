class DropOauthPluginTables < ActiveRecord::Migration
  def up
    # Keep nonces, we need those.
    drop_table :oauth_tokens
    drop_table :client_applications
  end

  def down
    create_table :client_applications do |t|
      t.string :name
      t.string :url
      t.string :support_url
      t.string :callback_url
      t.string :key, :limit => 40
      t.string :secret, :limit => 40
      t.integer :user_id

      t.timestamps
    end
    add_index :client_applications, :key, :unique => true

    create_table :oauth_tokens do |t|
      t.integer :user_id
      t.string :type, :limit => 20
      t.integer :client_application_id
      t.string :token, :limit => 40
      t.string :secret, :limit => 40
      t.string :callback_url
      t.string :verifier, :limit => 20
      t.string :scope
      t.timestamp :authorized_at, :invalidated_at, :expires_at
      t.timestamps
    end

    add_index :oauth_tokens, :token, :unique => true

  end
end
