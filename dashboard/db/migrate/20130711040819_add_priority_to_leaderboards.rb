class AddPriorityToLeaderboards < ActiveRecord::Migration
  def change
    add_column :leaderboards, :priority, :integer, :null => false, :default => 100
  end
end
