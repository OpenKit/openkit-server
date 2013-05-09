class AddCustomIdToOkUsers < ActiveRecord::Migration
  def change
    add_column :users, :custom_id, 'bigint UNSIGNED'
    add_index  :users, :custom_id, :name => "index_users_on_custom_id"
  end
end
