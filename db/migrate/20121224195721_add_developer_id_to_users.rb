class AddDeveloperIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :developer_id, :integer
    add_index "users", ["developer_id"], :name => "index_users_on_developer_id"
  end
end
