require_relative 'base_request.rb'

# Delete.from('/path')
module OpenKit
  class Delete < BaseRequest
    def self.from(path)
      new(path).perform
    end

    def initialize(path)
      super :delete, path
    end

    private
    def net_request
      net_request = Net::HTTP::Delete.new(uri.request_uri)
      net_request.set_body_internal(@req_params.to_json)
      set_headers(net_request)
      net_request
    end
  end
end