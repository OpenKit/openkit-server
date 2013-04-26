class RemoveAppidFromAchievementScores < ActiveRecord::Migration
  def up
	remove_column :achievement_scores, :app_id
  end

  def down
	add_column :achievement_scores, :app_id
  end
end
