require_relative 'base_request.rb'

# upload = Upload.new('score[meta_doc]', 'path-to-file')
# PostMultipart.to('/path', {param1: 'foo'}, upload)
module OpenKit
  class Upload
    attr_accessor :param_name, :filepath

    def initialize(param_name, filepath)
      @param_name = param_name
      @filepath = filepath
    end

    def file
      @file ||= File.open(@filepath)
    end

    def close
      @file.close if @file  # Use ivar directly, not the #file method.
    end
  end


  class PostMultipart < BaseRequest
    attr_reader :upload

    def self.to(path, req_params, upload)
      new(path, req_params, upload).perform
    end

    def initialize(path, req_params, upload)
      super :post, path
      @req_params = req_params
      @upload = upload
    end

    def perform
      response = super
      @upload.close
      response
    end

    private
    def net_request
      flat_params = flatten_params(@req_params)
      net_request = Net::HTTP::Post::Multipart.new(uri.request_uri, flat_params.merge(@upload.param_name => UploadIO.new(@upload.file, "application/octet-stream", "upload")))
      set_headers(net_request)
      net_request
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

    def flatten_params(parameters)
      flattened = {}
      flat_names(parameters, '') do |name,v|
        flattened[name] = v
      end
      flattened
    end

    def set_headers(net_request)
      net_request['Accept'] = "application/json"
      net_request['Authorization'] = authorization_header
    end
  end
end
