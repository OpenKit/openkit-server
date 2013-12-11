module OpenKit
  module Request

    class BaseDelegate
      attr_reader :scheme, :host, :app_key, :secret_key
      attr_reader :path

      def initialize(path)
        raise "Don't instantiate me!" if abstract_class?

        raise "OpenKit::Config.host is not set." unless Config.host
        raise "OpenKit::Config.app_key is not set." unless Config.app_key
        raise "OpenKit::Config.secret_key is not set." unless Config.secret_key

        @scheme     = Config.skip_https ? "http" : "https"
        @host       = Config.host
        @app_key    = Config.app_key
        @secret_key = Config.secret_key

        @path = path
      end

      def base_uri
        @scheme + "://" + @host
      end

      def uri
        @uri ||= URI(base_uri + @path)
      end

      private
      def abstract_class?
        self.class == BaseDelegate
      end
    end
  end
end
