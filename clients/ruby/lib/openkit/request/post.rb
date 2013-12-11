# Post.to('/path', {param1: 'foo'})
module OpenKit
  module Request

    class Post < Base

      def self.to(path, req_params)
        new(path, req_params).perform
      end

      def initialize(path, req_params)
        super :post, PostDelegate.new(path, req_params)
      end
    end


    class PostDelegate < BaseDelegate

      def initialize(path, req_params)
        super(path)
        @req_params = req_params
      end

      def net_request
        req = Net::HTTP::Post.new(uri.request_uri)
        req.set_body_internal(@req_params.to_json)
        req['Content-Type'] = "application/json; charset=utf-8"
        req['Accept'] = "application/json"
        req
      end
    end
  end
end
