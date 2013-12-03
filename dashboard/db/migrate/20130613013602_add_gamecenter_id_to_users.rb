class AddGamecenterIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gamecenter_id, :string
    add_index  :users, :gamecenter_id, :name => "index_users_on_gamecenter_id"
  end
end
