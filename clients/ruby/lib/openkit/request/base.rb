module OpenKit
  module Request

    class Base
      def initialize(verb, the_delegate)
        raise "Don't instantiate me!" if abstract_class?

        @delegate         = the_delegate
        @nonce            = SecureRandom.uuid
        @oauth_version    = '1.0'
        @signature_method = 'HMAC-SHA1'
        @timestamp        = Time.now.to_i
        @verb             = verb
      end

      def perform
        http = Net::HTTP.new(@delegate.uri.host, @delegate.uri.port)
        http.use_ssl = (@delegate.scheme == 'https')
        http.start do
          response = http.request(self.net_request)
          response
        end
      end

      def net_request
        net_request = @delegate.net_request()
        net_request['Authorization'] = authorization_header
        net_request
      end

      private
      def authorization_header
        %|OAuth oauth_consumer_key="#{@delegate.app_key}", oauth_nonce="#{@nonce}", oauth_signature="#{escape(signature)}", oauth_signature_method="#{@signature_method}", oauth_timestamp="#{@timestamp}", oauth_version="#{@oauth_version}"|
      end

      def signature
        k = @delegate.secret_key + "&"
        hmac = Digest::HMAC.digest(signature_base_string, k, Digest::SHA1)
        Base64.encode64(hmac).chomp
      end

      def signature_base_string
        [ @verb.to_s.upcase,
          escape(@delegate.base_uri + @delegate.uri.path),
          escape(params_string_for_signature)
        ].join('&')
      end

      def params_string_for_signature
        params_in_signature.sort_by{|k, _| k}.collect{ |k,v| k.to_s + '=' + v.to_s }.join("&")
      end

      def params_in_signature
        {
          oauth_consumer_key:       @delegate.app_key,
          oauth_nonce:              @nonce,
          oauth_signature_method:   @signature_method,
          oauth_timestamp:          @timestamp,
          oauth_version:            @oauth_version,
        }
      end

      def escape(s)
        CGI.escape(s)
      end

      def abstract_class?
        self.class == Base
      end
    end
  end
end
