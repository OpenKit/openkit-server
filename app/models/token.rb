class Token < ActiveRecord::Base
  attr_accessible :apns_token, :app_id, :user_id
end
