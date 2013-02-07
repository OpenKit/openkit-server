class RenameApplicationsApps < ActiveRecord::Migration
  def up
    rename_table :applications, :apps
    rename_column :leaderboards, :application_id, :app_id
  end

  def down
    rename_column :leaderboards, :app_id, :application_id
    rename_table :apps, :applications
  end
end
