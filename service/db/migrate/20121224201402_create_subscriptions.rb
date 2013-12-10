class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :app
      t.references :user

      t.timestamps
    end
    add_index :subscriptions, :app_id
    add_index :subscriptions, :user_id
  end
end
