class AddPerishableTokenToDevelopers < ActiveRecord::Migration
  def up
    add_column :developers, :perishable_token, :string, :default => "", :null => false
    add_index :developers, [:perishable_token]
  end

  def down
    remove_index :developers, :column => [:perishable_token]
    remove_column :developers, :perishable_token
  end
end
