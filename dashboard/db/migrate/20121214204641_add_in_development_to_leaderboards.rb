class AddInDevelopmentToLeaderboards < ActiveRecord::Migration
  def change
    add_column :leaderboards, :in_development, :boolean, :default => true
  end
end
