class AddFeatureListToApps < ActiveRecord::Migration
  def change
    add_column :apps, :feature_list, :string
  end
end
