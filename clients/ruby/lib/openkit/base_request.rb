require 'securerandom'
require 'net/http'
require 'net/http/post/multipart'
require 'digest/hmac'
require 'base64'
require 'cgi'
require 'json'
require 'pp'

module OpenKit

  class BaseRequest
    def initialize(verb, path)
      raise "Don't instantiate me!" if abstract_class?
      @verb = verb
      @path = path
      @timestamp  = Time.now.to_i
      @nonce      = SecureRandom.uuid
      @scheme     = Config.skip_https ? "http" : "https"
      @host       = ENV["HOST"] || "local.openkit.io:3003"
    end

    def base_uri
      @scheme + "://" + @host
    end

    def uri
      @uri ||= URI(base_uri + @path)
    end

    def params_in_signature
      {
        oauth_consumer_key:       Config.app_key,
        oauth_nonce:              @nonce,
        oauth_signature_method:   'HMAC-SHA1',
        oauth_timestamp:          @timestamp,
        oauth_version:            '1.0',
      }
    end

    def perform
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true unless Config.skip_https
      http.start do
        response = http.request(net_request)
        response
      end
    end

    def net_request
      raise "no."
    end

    private
    def authorization_header
      %|OAuth oauth_consumer_key="#{Config.app_key}", oauth_nonce="#{@nonce}", oauth_signature="#{escape(signature)}", oauth_signature_method="HMAC-SHA1", oauth_timestamp="#{@timestamp}", oauth_version="1.0"|
    end

    def signature
      signatureBaseString = "#{@verb.to_s.upcase}&#{escape(base_uri + uri.path)}&#{escape(params_string_for_signature)}"
      k = "#{Config.secret_key}&"  # <-- note the &
      hmac = Digest::HMAC.digest(signatureBaseString, k, Digest::SHA1)
      Base64.encode64(hmac).chomp
    end

    def params_string_for_signature
      params_in_signature.sort_by{|k, _| k}.collect{ |k,v| k.to_s + '=' + v.to_s }.join("&")
    end

    def escape(s)
      CGI.escape(s)
    end

    def abstract_class?
      self.class == BaseRequest
    end

    def set_headers(net_request)
      net_request['Content-Type'] = "application/json; charset=utf-8"
      net_request['Accept'] = "application/json"
      net_request['Authorization'] = authorization_header
    end
  end
end
