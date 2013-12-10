class Turn < ActiveRecord::Base
  attr_accessible :uuid, :meta_doc, :user_id
  has_attached_file :meta_doc
end
