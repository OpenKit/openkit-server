class CreateTurns < ActiveRecord::Migration
  def up
    create_table :turns do |t|
      t.string "uuid"
      t.integer "user_id"
      t.timestamps
    end

    add_attachment :turns, :meta_doc
  end

  def down
    remove_attachment :turns, :meta_doc

    drop_table :turns
  end
end
