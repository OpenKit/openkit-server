class AddAttachmentIconHeaderImageToLeaderboards < ActiveRecord::Migration
  def self.up
    change_table :leaderboards do |t|
      t.has_attached_file :icon
      t.has_attached_file :header_image
    end
  end

  def self.down
    drop_attached_file :leaderboards, :icon
    drop_attached_file :leaderboards, :header_image
  end
end
