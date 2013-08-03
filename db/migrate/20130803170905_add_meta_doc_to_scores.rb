class AddMetaDocToScores < ActiveRecord::Migration
  def up
    add_attachment :scores, :meta_doc
  end

  def down
    remove_attachment :scores, :meta_doc
  end
end
