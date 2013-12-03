class DropHeaderFromApps < ActiveRecord::Migration
  def up
    drop_attached_file :apps, :header_image
  end

  def down
    change_table :apps do |t|
      t.has_attached_file :header_image
    end
  end
end
