class AchievementsTouchup < ActiveRecord::Migration
  def up
    remove_index 'achievements',             :name => 'index_achievements_on_game_id'
    add_index    'achievements', ['app_id'], :name => 'index_achievements_on_app_id'
  end

  def down
    remove_index 'achievements',             :name => 'index_achievements_on_app_id'
    add_index    'achievements', ['app_id'], :name => 'index_achievements_on_game_id'
  end
end
