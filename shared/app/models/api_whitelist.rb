class ApiWhitelist < ActiveRecord::Base
  attr_accessible :app_key, :version
end
