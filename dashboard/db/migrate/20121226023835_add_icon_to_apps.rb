class AddIconToApps < ActiveRecord::Migration
  def up
    change_table :apps do |t|
      t.has_attached_file :icon
    end
  end

  def down
    drop_attached_file :apps, :icon
  end
end
