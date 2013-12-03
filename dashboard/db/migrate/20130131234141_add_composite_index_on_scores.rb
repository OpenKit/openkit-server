class AddCompositeIndexOnScores < ActiveRecord::Migration
  def up
    add_index :scores, [:leaderboard_id, :user_id, :value]
  end

  def down
    remove_index :scores, :column => [:leaderboard_id, :user_id, :value]
  end
end
