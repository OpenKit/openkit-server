class AddIndexOnSortValue < ActiveRecord::Migration
  def up
    add_index :scores, [:leaderboard_id, :sort_value, :created_at], :order => {:sort_value => :desc}, :name => "index_scores_composite_1"
  end

  def down
    remove_index :scores, :name => "index_scores_composite_1"
  end
end
