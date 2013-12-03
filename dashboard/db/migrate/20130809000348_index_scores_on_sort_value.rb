class IndexScoresOnSortValue < ActiveRecord::Migration
  def up
    remove_index "scores", :name => "index_scores_on_leaderboard_id_and_user_id"

    add_index :scores, [:leaderboard_id, :sort_value, :created_at], :order => {:sort_value => :desc}, :name => "index_scores_composite_1"
    add_index :scores, [:leaderboard_id, :user_id, :sort_value, :created_at], :order => {:sort_value => :desc}, :name => "index_scores_composite_2"
  end

  def down
    remove_index :scores, :name => "index_scores_composite_2"
    remove_index :scores, :name => "index_scores_composite_1"

    add_index "scores", ["leaderboard_id", "user_id"], :name => "index_scores_on_leaderboard_id_and_user_id"
  end
end
