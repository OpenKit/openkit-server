class DropInDevelopment < ActiveRecord::Migration
  def up
    remove_column :achievements, :in_development
    remove_column :leaderboards, :in_development
  end

  def down
    add_column :leaderboards, :in_development, :boolean, :default => true
    add_column :achievements, :in_development, :boolean, :default => true
  end
end
