class AddGameCenterAndGoogleToLeaderboard < ActiveRecord::Migration
  def up
    add_column :leaderboards, :gamecenter_id, :string
    add_column :leaderboards, :gpg_id, :string
  end
  
  def down
    remove_column :leaderboards, :gamecenter_id
    remove_column :leaderboards, :gpg_id
  end
end
