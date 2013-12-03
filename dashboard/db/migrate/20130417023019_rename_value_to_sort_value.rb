class RenameValueToSortValue < ActiveRecord::Migration
  def up
    rename_column :scores, :value, :sort_value
  end

  def down
    rename_column :scores, :sort_value, :value
  end
end
