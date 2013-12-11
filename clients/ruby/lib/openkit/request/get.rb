# Get.from('/path', {query_param1: 'foo'})
module OpenKit
  module Request

    class Get < Base

      def self.from(path, query_params = {})
        new(path, query_params).perform
      end

      def initialize(path, query_params = {})
        super :get, GetDelegate.new(path, query_params)
        @query_params = query_params
      end

      def params_in_signature
        super.merge(@query_params)
      end
    end


    class GetDelegate < BaseDelegate
      attr_accessor :query_params

      def initialize(path, query_params)
        super(path)
        @query_params = query_params
      end

      def net_request
        req = Net::HTTP::Get.new(uri.request_uri + "?" + params_to_query(@query_params))
        req['Content-Type'] = "application/json; charset=utf-8"
        req['Accept'] = "application/json"
        req
      end

      def params_to_query(h)
        return '' if h.empty?
        h.collect { |k, v| "#{k.to_s}=#{v.to_s}" }.join('&')
      end
    end
  end
end
