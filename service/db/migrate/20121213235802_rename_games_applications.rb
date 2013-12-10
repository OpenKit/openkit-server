class RenameGamesApplications < ActiveRecord::Migration
  def up
    rename_table :apps, :applications
    rename_column :leaderboards, :game_id, :application_id
  end

  def down
    rename_column :leaderboards, :application_id, :game_id
    rename_table :applications, :apps
  end
end
