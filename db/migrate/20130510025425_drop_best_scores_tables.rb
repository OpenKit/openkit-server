class DropBestScoresTables < ActiveRecord::Migration
  def up
    remove_index "best_scores_7", :name => "index_best_scores_7_on_leaderboard_id"
    remove_index "best_scores_7", :name => "index_best_scores_7_on_created_at"

    drop_table "best_scores_7"

    remove_index "best_scores_1", :name => "index_best_scores_1_on_leaderboard_id"
    remove_index "best_scores_1", :name => "index_best_scores_1_on_created_at"

    drop_table "best_scores_1"

    remove_index "best_scores", :name => "index_best_scores_on_leaderboard_id"
    remove_index "best_scores", :name => "index_best_scores_on_created_at"

    drop_table "best_scores"
  end

  def down
    create_table "best_scores", :force => true do |t|
      t.integer  "leaderboard_id",              :null => false
      t.integer  "user_id",                     :null => false
      t.integer  "score_id",                    :null => false
      t.integer  "value",          :limit => 8, :null => false
      t.datetime "created_at",                  :null => false
      t.integer  "metadata"
      t.string   "display_string"
    end

    add_index "best_scores", ["created_at"], :name => "index_best_scores_on_created_at"
    add_index "best_scores", ["leaderboard_id"], :name => "index_best_scores_on_leaderboard_id"

    create_table "best_scores_1", :force => true do |t|
      t.integer  "leaderboard_id",              :null => false
      t.integer  "user_id",                     :null => false
      t.integer  "score_id",                    :null => false
      t.integer  "value",          :limit => 8, :null => false
      t.datetime "created_at",                  :null => false
      t.integer  "metadata"
      t.string   "display_string"
    end

    add_index "best_scores_1", ["created_at"], :name => "index_best_scores_1_on_created_at"
    add_index "best_scores_1", ["leaderboard_id"], :name => "index_best_scores_1_on_leaderboard_id"

    create_table "best_scores_7", :force => true do |t|
      t.integer  "leaderboard_id",              :null => false
      t.integer  "user_id",                     :null => false
      t.integer  "score_id",                    :null => false
      t.integer  "value",          :limit => 8, :null => false
      t.datetime "created_at",                  :null => false
      t.integer  "metadata"
      t.string   "display_string"
    end

    add_index "best_scores_7", ["created_at"], :name => "index_best_scores_7_on_created_at"
    add_index "best_scores_7", ["leaderboard_id"], :name => "index_best_scores_7_on_leaderboard_id"
  end
end
