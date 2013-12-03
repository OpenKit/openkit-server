class CreateClientSessions < ActiveRecord::Migration
  def change
    create_table :client_sessions do |t|
      t.string :uuid
      t.string :fb_id
      t.string :google_id
      t.string :custom_id
      t.string :ok_id
      t.string :push_token
      t.string :client_db_version
      t.datetime :client_created_at

      t.timestamps
    end
  end
end
