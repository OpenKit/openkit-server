class AddDisplayStringToScores < ActiveRecord::Migration
  def up
    rename_column :scores, :display_value, :display_string
    add_column :best_scores, :display_string, :string
    add_column :best_scores_1, :display_string, :string
    add_column :best_scores_7, :display_string, :string
  end
  def down
    rename_column :scores, :display_string, :display_value
    remove_column :best_scores, :display_string
    remove_column :best_scores_1, :display_string
    remove_column :best_scores_7, :display_string
  end
end
