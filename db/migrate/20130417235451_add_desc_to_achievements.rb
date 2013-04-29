class AddDescToAchievements < ActiveRecord::Migration
  def change
    add_column :achievements, :desc, :text
  end
end
