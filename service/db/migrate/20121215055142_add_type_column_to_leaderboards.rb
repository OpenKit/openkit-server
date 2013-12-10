class AddTypeColumnToLeaderboards < ActiveRecord::Migration
  def change
    add_column :leaderboards, :type, :string
  end
end
