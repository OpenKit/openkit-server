class DropSlugFromApps < ActiveRecord::Migration
  def up
    remove_index :apps, ["developer_id", "slug"]
    remove_column :apps, :slug
  end

  def down
    add_column :apps, :slug, :string
    add_index "apps", ["developer_id", "slug"], name: "index_apps_on_developer_id_and_slug", using: :btree
  end
end
