class AddCustomIdToOkUsers < ActiveRecord::Migration
  def change
    add_column :users, :custom_id, 'bigint UNSIGNED'
  end
end
