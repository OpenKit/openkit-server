class RenameAchievementProgress < ActiveRecord::Migration
  def up
	rename_table :achievement_progress, :achievement_scores
  end

  def down
	rename_table :achievement_scores, :achievement_progress
  end
end
