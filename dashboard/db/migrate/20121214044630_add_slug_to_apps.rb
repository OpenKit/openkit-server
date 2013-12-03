class AddSlugToApps < ActiveRecord::Migration
  def change
    add_column :apps, :slug, :string
    add_index :apps, :slug, unique: true
  end
end
