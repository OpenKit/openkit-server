class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :name
      t.references :developer

      t.timestamps
    end
    add_index :apps, :developer_id
  end
end
