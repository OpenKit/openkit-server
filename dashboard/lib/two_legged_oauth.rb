require 'oauth'
require 'oauth/request_proxy/rack_request'

class TwoLeggedOAuth
  def initialize(app)
    @app = app
  end

  def h
    {"Content-Type" => "application/json"}
  end

  def redis
    OKRedis.connection
  end

  def call(env)
    request = Rack::Request.new(env)
    req_proxy = OAuth::RequestProxy.proxy(request)

    # TODO: Add...
    #unless env['HTTP_AUTHORIZATION']
    #  return [401, h, [{message: "This service requires an oauth 1.0a authorization header. Email lou@openkit.io."}.to_json]]
    #end

    # TODO: Remove...
    if env['HTTP_AUTHORIZATION'].nil?
      return @app.call(env) if request.host =~ /^(beta-)?developer/   # Rely on developer creds for dashboard access.

      # Either authorized_app is set via old API whitelist, or access denied.
      if request.host == "stage.openkit.io"
        app_key = request.params["app_key"] || (env["action_dispatch.request.request_parameters"] && env["action_dispatch.request.request_parameters"]["app_key"])
        if app_key && ::ApiWhitelist.where({app_key: app_key, version: "0.8"}).first
          # Made it!
          request.env[:authorized_app] = App.find_by(app_key: app_key)
          return @app.call(env)
        else
          return [401, {}, ["The developer dashboard is now at developer.openkit.io.  Please email team@openkit.io for help."]]
        end
      end
      return [401, {}, ["You must use oauth 1.0a to access this API.  Please email team@openkit.io for help."]]
    end

    missing_header = %w(oauth_consumer_key oauth_nonce oauth_signature_method oauth_timestamp oauth_version oauth_signature).detect { |x|
      val = req_proxy.send(x)
      (val == nil || val.length < 1)
    }
    unless !missing_header
      return [401, h, [{message: 'Bad authorization header'}.to_json]]
    end

    unless (req_proxy.oauth_timestamp.to_i - Time.now.to_i).abs < 172800   # purge window
      return [401, h, [{message: 'Invalid time in authorization header'}.to_json]]
    end

    sk = redis.get("sk:#{req_proxy.consumer_key}")
    unless sk
      return [401, h, [{message: "No secret key found! Email lou@openkit.io"}.to_json]]
    end

    signature = OAuth::Signature::HMAC::SHA1.new(req_proxy, {}) { |req_proxy|
      [nil, sk]
    }

    unless signature.verify
      return [401, h, [{message: "Request signature failed"}.to_json]]
    end

    unless redis.sadd("oauth_nonce", "#{req_proxy.oauth_timestamp}:#{req_proxy.oauth_nonce}")
      return [401, h, [{message: "Nonce has already been used."}.to_json]]
    end

    request.env[:authorized_app] = App.find_by(app_key: req_proxy.consumer_key)
    @app.call(env)
  end
end
