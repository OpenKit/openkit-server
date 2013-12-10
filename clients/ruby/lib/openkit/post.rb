require_relative 'base_request.rb'

# Post.to('/path', {param1: 'foo'})
module OpenKit
  class Post < BaseRequest
    class << self
      def to(path, req_params)
        new(path, req_params).perform
      end
    end

    def initialize(path, req_params)
      super :post, path
      @req_params = req_params
    end

    def net_request
      net_request = Net::HTTP::Post.new(uri.request_uri)
      net_request.set_body_internal(@req_params.to_json)
      set_headers(net_request)
      net_request
    end
  end
end
