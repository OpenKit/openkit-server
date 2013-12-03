class CreateAchievements < ActiveRecord::Migration
  def change
  create_table "achievements", :force => true do |t|
    t.string   "name"
    t.integer  "app_id"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.string   "icon_locked_file_name"
    t.string   "icon_locked_content_type"
    t.integer  "icon_locked_file_size"
    t.datetime "icon_locked_updated_at"
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.boolean  "in_development",                  :default => true
  end

  add_index "achievements", ["app_id"], :name => "index_achievements_on_game_id"

  end
end
