class DropStiFromLeaderboards < ActiveRecord::Migration
  def up
    remove_column :leaderboards, :type
    add_column :leaderboards, :sort_type, :string, :limit => 20
  end

  def down
    remove_column :leaderboards, :sort_type
    add_column :leaderboards, :type, :string
  end
end
