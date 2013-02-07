class RemoveUniqueFromAppSlug < ActiveRecord::Migration
  def up
    remove_index :apps, :column => ["slug"]
    add_index :apps, ["developer_id", "slug"]
  end

  def down
    remove_index :apps, :column => ["developer_id", "slug"]
    add_index :apps, ["slug"], :unique => true
  end
end
