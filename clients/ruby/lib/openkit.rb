module OpenKit

  class Config
    @host = 'api.openkit.io'  # default
    class << self
      attr_accessor :app_key, :secret_key
      attr_accessor :host
      attr_accessor :skip_https
    end
  end
end

require_relative 'openkit/request'
require_relative "openkit/version"

