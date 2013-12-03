class AddGoogleIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :google_id, 'bigint UNSIGNED'
    add_index  :users, :google_id, :name => "index_users_on_google_id"
  end
end
