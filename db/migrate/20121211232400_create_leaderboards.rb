class CreateLeaderboards < ActiveRecord::Migration
  def change
    create_table :leaderboards do |t|
      t.string :name
      t.references :game

      t.timestamps
    end
    add_index :leaderboards, :game_id
  end
end
