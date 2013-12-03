class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.float :value
      t.references :user
      t.references :leaderboard

      t.timestamps
    end
    add_index :scores, :user_id
    add_index :scores, :leaderboard_id
  end
end
