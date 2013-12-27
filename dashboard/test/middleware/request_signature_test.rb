# encoding=utf-8
#
# Here we test whether requests with bad signatures are rejected
# by the the two-legged oauth middleware.  We also ensure that requests
# with valid signatures make it through.
#
# Run by iteslf with:
#   ruby -Itest test/middleware/request_signature_test.rb
# or
#   zeus t test/middleware/request_signature_test.rb
# or
#   rake test TEST=test/middleware/request_signature_test.rb
require 'test_helper'
require_relative 'request_signature_test_helper'


class RequestSignatureTest < ActiveSupport::TestCase
  include Rack::Test::Methods
  include RequestSignatureTestHelper


  def app
    Rack::Builder.app do
      use TwoLeggedOAuth
      run -> env do
        body = env[:authorized_app].name
        [200, {}, [body]]
      end
    end
  end


  def setup
    @game = FactoryGirl.create(:app)
    OpenKit::Config.app_key    = @game.app_key
    OpenKit::Config.secret_key = @game.secret_key
  end


  def test_middleware_sets_authorized_app_on_valid_request
    path = '/foo'
    get(path, {}, rack_auth_for_get(path))
    assert last_response.ok?
    assert_equal @game.id, last_request.env[:authorized_app].id
  end


  def test_no_signature_fails
    get '/foo'
    assert_equal 401, last_response.status
  end


  def test_bad_signature_fails
    bad_sig = "zWzJOMtJ8uOv8aK6vnwSEs93Jy4%3D"
    path = '/foo'
    rack_auth = rack_auth_for_get(path)

    orig = rack_auth['HTTP_AUTHORIZATION'].clone
    rack_auth['HTTP_AUTHORIZATION'].sub!(/(oauth_signature=\").+?(\")/, '\1' + bad_sig + '\2')

    # Make sure we didn't hose the header.  And account for URI encoded chars.
    assert_equal URI.decode(orig).length, URI.decode(rack_auth['HTTP_AUTHORIZATION']).length

    get(path, {}, rack_auth)
    assert_equal 401, last_response.status
    assert_match /signature failed/i, last_response.body
  end


  def test_replay_fails
    path = '/bar'
    # Create a couple different headers:
    auth1 = rack_auth_for_get(path)
    auth2 = rack_auth_for_get(path)

    # Verify that back to back requests normally pass:
    get(path, {}, auth1)
    assert last_response.ok?
    get(path, {}, auth2)
    assert last_response.ok?

    # And the same headers fail:
    get(path, {}, auth1)
    assert_equal 401, last_response.status
    get(path, {}, auth2)
    assert_equal 401, last_response.status
  end


  def test_get_with_query
    path = '/bar?whatever=foo'
    auth = rack_auth_for_get(path)
    get(path, {}, auth)
    assert last_response.ok?
  end


  def test_post
    path = '/score'
    params = {:value => 100}
    auth = rack_auth_for_post(path, params)
    post(path, params, auth.merge({"CONTENT_TYPE" => "application/json"}))
    assert last_response.ok?
  end


  def test_put
    path = '/user'
    params = {:nick => 'lou'}
    auth = rack_auth_for_put(path, params)
    put(path, params, auth.merge({"CONTENT_TYPE" => "application/json"}))
    assert last_response.ok?
  end


  def test_post_multipart
    file = Tempfile.new('immafile')
    begin
      file.write("hello world")
      file.rewind

      params = {score: {user_id: 1}}
      auth = rack_auth_for_multi('/score', params, file.path, 'score[meta]')
      upload_file = Rack::Test::UploadedFile.new(file.path, "application/octet-stream")

      post('/score', params[:score].merge(:meta => upload_file), auth)
      assert_match /hello world/, last_request.body.read
      assert last_response.ok?
    ensure
      file.close
      file.unlink
    end
  end
end
