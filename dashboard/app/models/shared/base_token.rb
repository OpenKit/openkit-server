module BaseToken

  def self.included(base)
    base.attr_accessible :apns_token, :app_id, :user_id
    base.belongs_to :app
    base.belongs_to :user
    base.send :extend,  ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
  end

  module InstanceMethods
  end
end
