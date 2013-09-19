class CreateSandboxScores < ActiveRecord::Migration
  def up
    create_table "sandbox_scores", :force => true do |t|
      t.integer  "sort_value",            :limit => 8, :null => false
      t.integer  "user_id"
      t.integer  "leaderboard_id"
      t.datetime "created_at",                         :null => false
      t.string   "display_string"
      t.integer  "metadata"
      t.string   "meta_doc_file_name"
      t.string   "meta_doc_content_type"
      t.integer  "meta_doc_file_size"
      t.datetime "meta_doc_updated_at"
    end

    add_index "sandbox_scores", ["leaderboard_id", "sort_value", "created_at"], :name => "index_sandbox_scores_composite_1"
    add_index "sandbox_scores", ["leaderboard_id", "user_id", "sort_value", "created_at"], :name => "index_sandbox_scores_composite_2"
  end

  def down
    remove_index "sandbox_scores", :name => "index_sandbox_scores_composite_2"
    remove_index "sandbox_scores", :name => "index_sandbox_scores_composite_1"
    drop_table "sandbox_scores"
  end
end
