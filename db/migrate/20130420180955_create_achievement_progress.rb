class CreateAchievementProgress < ActiveRecord::Migration
  def change 
  create_table "achievement_progress", :force => true do |t|
    t.integer  "app_id"
    t.integer  "user_id"
    t.integer  "achievement_id"
    t.integer  "progress"
    t.datetime "created_at",                                        :null => false
  end

  add_index "achievement_progress", ["app_id", "user_id", "achievement_id"], :name => "index_achievement_progress_on_app_user_and_achievement_id"
  add_index "achievement_progress", ["app_id", "user_id"], :name => "index_achievement_progress_on_app_and_user_id"

  end

end
