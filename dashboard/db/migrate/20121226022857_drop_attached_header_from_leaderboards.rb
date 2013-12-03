class DropAttachedHeaderFromLeaderboards < ActiveRecord::Migration
  def up
    drop_attached_file :leaderboards, :header_image
    change_table :apps do |t|
      t.has_attached_file :header_image
    end
  end

  def down
    drop_attached_file :apps, :header_image
    change_table :leaderboards do |t|
      t.has_attached_file :header_image
    end
  end
end
