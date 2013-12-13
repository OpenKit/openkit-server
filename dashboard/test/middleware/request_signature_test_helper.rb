module RequestSignatureTestHelper

  def self.included(base)
    OpenKit::Config.skip_https = true     # to match rack-test
    OpenKit::Config.host = "example.org"  # to match rack-test
  end

  def request_signature_test_app
    Rack::Builder.app do
      use TwoLeggedOAuth
      run -> env do
        body = env[:authorized_app].name
        [200, {}, [body]]
      end
    end
  end

  # This creates a new GET request using the openkit gem, but it doesn't
  # perform the request.  We are using it to get the authorization header
  # that we need for a succesful request through the two_legged_oauth middleware.
  def rack_auth_for_get(path)
    uri = URI(path)
    query_params = uri.query && Rack::Utils.parse_query(uri.query) || {}
    r = OpenKit::Request::Get.new(path, query_params)
    rack_auth_header(r.net_request)
  end

  def rack_auth_for_post(path, params)
    r = OpenKit::Request::Post.new(path, params)
    rack_auth_header(r.net_request)
  end

  def rack_auth_for_put(path, params)
    r = OpenKit::Request::Put.new(path, params)
    rack_auth_header(r.net_request)
  end

  def rack_auth_for_multi(path, params, filepath, file_param)
    upload = OpenKit::Request::Upload.new(file_param, filepath)
    r = OpenKit::Request::PostMultipart.new(path, params, upload)
    rack_auth_header(r.net_request)
  end

  private
  def rack_auth_header(net_http_request)
    {'HTTP_AUTHORIZATION' => net_http_request['AUTHORIZATION']}
  end
end
