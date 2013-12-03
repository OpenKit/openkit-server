class AddGoalToAchievements < ActiveRecord::Migration
  def change
    add_column :achievements, :goal, :integer
  end
end
