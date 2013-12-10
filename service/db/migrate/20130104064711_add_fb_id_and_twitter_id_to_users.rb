class AddFbIdAndTwitterIdToUsers < ActiveRecord::Migration
  def up
    add_column :users, :twitter_id, 'bigint UNSIGNED'
    add_column :users, :fb_id, 'bigint UNSIGNED'

    add_index :users, [:twitter_id]
    add_index :users, [:fb_id]
  end

  def down
    remove_index :users, :column => [:fb_id]
    remove_index :users, :column => [:twitter_id]

    remove_column :users, :fb_id
    remove_column :users, :twitter_id
  end
end
