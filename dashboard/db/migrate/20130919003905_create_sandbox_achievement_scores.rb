class CreateSandboxAchievementScores < ActiveRecord::Migration
  def up
    create_table "sandbox_achievement_scores", :force => true do |t|
      t.integer  "user_id"
      t.integer  "achievement_id"
      t.integer  "progress"
      t.datetime "created_at",     :null => false
    end
    add_index "sandbox_achievement_scores", ["user_id", "achievement_id"]
    add_index "sandbox_achievement_scores", ["user_id"]
  end

  def down
    remove_index "sandbox_achievement_scores", :column => ["user_id"]
    remove_index "sandbox_achievement_scores", :column => ["user_id", "achievement_id"]
    drop_table "sandbox_achievement_scores"
  end
end
