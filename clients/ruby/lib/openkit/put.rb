require_relative 'base_request.rb'

# Put.to('/path', {param1: 'foo'})
module OpenKit
  class Put < BaseRequest
    def self.to(path, req_params)
      new(path, req_params).perform
    end

    def initialize(path, req_params)
      super :put, path
      @req_params = req_params
    end

    def net_request
      net_request = Net::HTTP::Put.new(uri.request_uri)
      net_request.set_body_internal(@req_params.to_json)
      set_headers(net_request)
      net_request
    end
  end
end

