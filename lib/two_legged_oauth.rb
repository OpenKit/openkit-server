require 'oauth'
require 'oauth/request_proxy/rack_request'

class TwoLeggedOAuth
  def initialize(app)
    @app = app
  end

  def call(env)
    # In our application controller, we will check for an App at request.env[:authorized_app].
    # If it doesn't exist, then the developer must provide credentials (i.e. access through dashboard)
    request = Rack::Request.new(env)
    request.env[:authorized_app] = nil
    if env['HTTP_AUTHORIZATION'].nil?
      return @app.call(env)
    end

    # For debug, may inspect oauth params with:
    # oauth_params = SimpleOAuth::Header.parse(env['HTTP_AUTHORIZATION'])

    authorizing_app = nil
    req_proxy = OAuth::RequestProxy.proxy(request)

    # There is no auth token for two-legged, so we return nil for token_secret in block.
    # See OAuth::Signature::Base#initialize of the oauth gem for format.
    signature = OAuth::Signature::HMAC::SHA1.new(req_proxy, {}) do |req_proxy|

      if req_proxy.oauth_version != '1.0'
        return [401, {}, ["Unauthorized. Please use OAuth 1.0"]]
      end

      authorizing_app = App.find_by_app_key(req_proxy.consumer_key)
      [nil, authorizing_app && authorizing_app.secret_key]
    end

    if !OauthNonce.remember(signature.request.nonce, signature.request.timestamp)
      return [400, {}, ["Bad Request.  Nonce has already been used."]]
    end

    if !signature.verify
      return [400, {}, ["Unauthorized.  OAuth 1.0 signature failed."]]
    end

    # Made it!
    request.env[:authorized_app] = authorizing_app
    @app.call(env)
  end

end
