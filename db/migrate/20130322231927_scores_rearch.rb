class ScoresRearch < ActiveRecord::Migration
  def up
    # Update scores indexes
    remove_index :scores, :column => [:leaderboard_id, :user_id, :value]
    remove_index :scores, :column => [:leaderboard_id]
    remove_index :scores, :column => [:user_id]

    # Score val is now an int
    change_column :scores, :value, :integer, :null => false

    # And there is a display column
    add_column :scores, :display_value, :string

    # Scores only get created , never updated
    remove_column :scores, :updated_at

    create_table :best_scores_1 do |t|
      t.integer  :leaderboard_id, :null => false
      t.integer  :user_id,        :null => false
      t.integer  :score_id,       :null => false
      t.integer  :value,          :null => false
      t.datetime :created_at,     :null => false
    end
    add_index "best_scores_1", ["leaderboard_id"]
    add_index "best_scores_1", ["created_at"]   # for reaper

    create_table :best_scores_7 do |t|
      t.integer  :leaderboard_id, :null => false
      t.integer  :user_id,        :null => false
      t.integer  :score_id,       :null => false
      t.integer  :value,          :null => false
      t.datetime :created_at,     :null => false
    end
    add_index "best_scores_7", ["leaderboard_id"]
    add_index "best_scores_7", ["created_at"]

    create_table :best_scores do |t|
      t.integer  :leaderboard_id, :null => false
      t.integer  :user_id,        :null => false
      t.integer  :score_id,       :null => false
      t.integer  :value,          :null => false
      t.datetime :created_at,     :null => false
    end
    add_index "best_scores", ["leaderboard_id"]
    add_index "best_scores", ["created_at"]


    # Query scores table on leaderboard_id and user_id
    add_index "scores", ["leaderboard_id", "user_id"]
  end

  def down
    remove_index "scores", :column => ["leaderboard_id", "user_id"]

    remove_index "best_scores", :column => ["created_at"]
    remove_index "best_scores", :column => ["leaderboard_id"]
    drop_table :best_scores

    remove_index "best_scores_7", :column => ["created_at"]
    remove_index "best_scores_7", :column => ["leaderboard_id"]
    drop_table :best_scores_7

    remove_index "best_scores_1", :column => ["created_at"] # for reaper
    remove_index "best_scores_1", :column => ["leaderboard_id"]
    drop_table :best_scores_1

    add_column :scores, :updated_at, :datetime, :null => false

    remove_column :scores, :display_value

    change_column :scores, :value, :decimal, :precision => 16, :scale => 2

    add_index :scores, [:user_id]
    add_index :scores, [:leaderboard_id]
    add_index :scores, [:leaderboard_id, :user_id, :value]
  end

end
