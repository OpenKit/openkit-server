require_relative 'base_request.rb'

# Get.from('/path', {query_param1: 'foo'})
module OpenKit
  class Get < BaseRequest
    class << self
      def from(path, query_params)
        new(path, query_params).perform
      end
    end

    def initialize(path, query_params)
      super :get, path
      @query_params = query_params
    end

    def params_in_signature
      super.merge(@query_params)
    end

    def net_request
      net_request = Net::HTTP::Get.new(uri.request_uri + "?" + params_to_query(@query_params))
      set_headers(net_request)
      net_request
    end

    def params_to_query(h)
      return '' if h.empty?
      h.collect { |k, v| "#{k.to_s}=#{v.to_s}" }.join('&')
    end
  end
end
