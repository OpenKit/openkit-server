class ClientSession < ActiveRecord::Base
  attr_accessible :client_created_at, :client_db_version, :custom_id, :fb_id, :google_id, :ok_id, :push_token, :uuid, :app_id
end
