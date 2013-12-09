require 'securerandom'
require 'net/http'
require 'net/http/post/multipart'
require 'digest/hmac'
require 'base64'
require 'cgi'
require 'json'
require 'pp'

# API:
#
# Get:
#   response = Req.new.get('/v1/leaderboards')
# Post:
#   response = Req.new.post('/v1/users', {:nick => 'lou'})
# Put:
#   response = Req.new.put('/v1/users/:id', {:nick => 'lou z'})
# Multipart Post:
#   upload = Upload.new('score[meta_doc]', 'path-to-file')    # The first param is the form param name to use for the file
#   response = Req.new.multipart_post('/v1/scores', {:score => {:value => 100}}, upload
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

  class Request

    class << self
      attr_accessor :skip_https
      attr_accessor :app_key, :secret_key
    end

    def initialize
      @timestamp  = Time.now.to_i
      @nonce      = SecureRandom.uuid
      @scheme     = self.class.skip_https ? "http" : "https"
      @host       = ENV["HOST"] || "local.openkit.io:3003"
      @params_in_signature = {
        oauth_consumer_key:       self.class.app_key,
        oauth_nonce:              @nonce,
        oauth_signature_method:   'HMAC-SHA1',
        oauth_timestamp:          @timestamp,
        oauth_version:            '1.0',
      }
    end


    def get(path, query_params = {})
      request(:get, path, query_params, nil)
    end

    def delete(path)
      request(:delete, path, nil, nil)
    end

    def put(path, req_params)
      request(:put, path, nil, req_params)
    end

    def post(path, req_params)
      request(:post, path, nil, req_params)
    end

    def multipart_post(path, req_params, upload)
      @upload = upload
      request(:post, path, nil, req_params)
    end

    def base_uri
      @scheme + "://" + @host
    end

    def request(verb, path, query_params, req_params)
      @verb = verb
      @path = path
      @query_params = query_params
      @req_params = req_params

      if is_get?
        @params_in_signature.merge!(@query_params)
      end

      if is_put? || is_post?
        @request_body = req_params.to_json
      end

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true unless self.class.skip_https
      http.start do
        if is_multipart?
          flat_params = flatten_params(@req_params)
          request = Net::HTTP::Post::Multipart.new(@uri.request_uri, flat_params.merge(@upload.param_name => UploadIO.new(@upload.file, "application/octet-stream", "upload")))
        else
          request = net_klass.new(@uri.request_uri)
          request.set_body_internal(@request_body) if @request_body
          request['Content-Type'] = "application/json; charset=utf-8"
        end
        request['Accept'] = "application/json"
        request['Authorization'] = authorization_header
        response = http.request(request)
        @upload.close if @upload
        response
      end
    end

    private
    def params_to_query(h)
      return '' if h.empty?
      h.collect { |k, v| "#{k.to_s}=#{v.to_s}" }.join('&')
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

    def uri
      @uri ||= begin
        if is_get? && !@query_params.empty?
          URI(base_uri + @path + "?" + params_to_query(@query_params))
        else
          URI(base_uri + @path)
        end
      end
    end

    def is_get?
      @verb == :get
    end

    def is_post?
      @verb == :post && @upload.nil?
    end

    def is_multipart?
      @verb == :post && @upload
    end

    def is_put?
      @verb == :put
    end

    def is_delete?
      @verb == :delete
    end

    def net_klass
      is_get?    && Net::HTTP::Get    ||
      is_post?   && Net::HTTP::Post   ||
      is_put?    && Net::HTTP::Put    ||
      is_delete? && Net::HTTP::Delete ||
      (raise "Doing it wrong.")
    end


    def authorization_header
      %|OAuth oauth_consumer_key="#{self.class.app_key}", oauth_nonce="#{@nonce}", oauth_signature="#{escape(signature)}", oauth_signature_method="HMAC-SHA1", oauth_timestamp="#{@timestamp}", oauth_version="1.0"|
    end

    def signature
      signatureBaseString = "#{@verb.to_s.upcase}&#{escape(base_uri + @uri.path)}&#{escape(params_string_for_signature)}"
      k = "#{self.class.secret_key}&"  # <-- note the &
      hmac = Digest::HMAC.digest(signatureBaseString, k, Digest::SHA1)
      Base64.encode64(hmac).chomp
    end

    def params_string_for_signature
      @params_in_signature.sort_by{|k, _| k}.collect{ |k,v| k.to_s + '=' + v.to_s }.join("&")
    end

    def escape(s)
      CGI.escape(s)
    end
  end
end
