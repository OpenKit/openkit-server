class AddAppKeyToApps < ActiveRecord::Migration
  def change
    add_column :apps, :app_key, :string, :limit => 20
    add_index :apps, [:app_key], :unique => true
  end
end
