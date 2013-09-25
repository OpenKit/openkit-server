module BaseClientSession

  def self.included(base)
    base.attr_accessible :client_created_at, :client_db_version, :custom_id, :fb_id, :google_id, :ok_id, :push_token, :uuid, :app_id
    base.send :extend,  ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
  end

  module InstanceMethods
  end
end
