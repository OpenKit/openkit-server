class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.integer :user_id
      t.integer :app_id
      t.string :apns_token
      t.datetime :created_at, :null => false
    end
    add_index :tokens, [:user_id, :app_id]
  end
end
