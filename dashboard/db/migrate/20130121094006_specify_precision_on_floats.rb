class SpecifyPrecisionOnFloats < ActiveRecord::Migration
  def up
    change_column :scores, :value, :decimal, :precision => 16, :scale => 2
  end

  def down
    change_column :scores, :value, :float
  end
end
