# Delete.from('/path')
module OpenKit
  module Request

    class Delete < Base

      def self.from(path)
        new(path).perform
      end

      def initialize(path)
        super :delete, DeleteDelegate.new(path)
      end
    end


    class DeleteDelegate < BaseDelegate

      def initialize(path)
        super(path)
      end

      def net_request
        req = Net::HTTP::Delete.new(uri.request_uri)
        req['Content-Type'] = "application/json; charset=utf-8"
        req['Accept'] = "application/json"
        req
      end
    end
  end
end
