class AddMetadataToBaseScore < ActiveRecord::Migration
  def up
    add_column :scores, :metadata, :integer
    add_column :best_scores, :metadata, :integer
    add_column :best_scores_1, :metadata, :integer
    add_column :best_scores_7, :metadata, :integer
  end
  def down
    remove_column :scores, :metadata
    remove_column :best_scores, :metadata
    remove_column :best_scores_1, :metadata
    remove_column :best_scores_7, :metadata
  end  
end
