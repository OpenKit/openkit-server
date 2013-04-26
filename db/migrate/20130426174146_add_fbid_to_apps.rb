class AddFbidToApps < ActiveRecord::Migration
  def change
    add_column :apps, :fbid, :string
  end
end
