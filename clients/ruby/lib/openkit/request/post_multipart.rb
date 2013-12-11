# upload = Upload.new('score[meta_doc]', 'path-to-file')
# PostMultipart.to('/path', {param1: 'foo'}, upload)
module OpenKit
  module Request


    class PostMultipart < Base
      attr_reader :upload

      def self.to(path, req_params, upload)
        new(path, req_params, upload).perform
      end

      def initialize(path, req_params, upload)
        super :post, PostMultipartDelegate.new(path, req_params, upload)
        @upload = upload
      end

      def perform
        response = super
        @upload.close
        response
      end
    end


    class PostMultipartDelegate < BaseDelegate

      def initialize(path, req_params, upload)
        super(path)
        @req_params = req_params
        @upload = upload
      end

      def net_request
        up_io = UploadIO.new(@upload.file, "application/octet-stream", "upload")
        flat_params = flatten_params(@req_params)
        req = Net::HTTP::Post::Multipart.new(uri.request_uri, flat_params.merge(@upload.param_name => up_io))
        req['Accept'] = "application/json"
        req
      end

      def flatten_params(parameters)
        flattened = {}
        flat_names(parameters, '') do |name,v|
          flattened[name] = v
        end
        flattened
      end

      def flat_names(parameters, running = '', &block)
        parameters.each do |k,v|
          name = (running.length == 0) ? k.to_s : running + "[#{k}]"
          if v.is_a?(Hash)
            flat_names(v, name, &block)
          else
            yield name, v
          end
        end
      end
    end
  end
end
