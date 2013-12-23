ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require File.expand_path("../middleware/request_signature_test_helper", __FILE__)
require "rails/test_help"
require 'mocha/setup'
require 'authlogic/test_case'
include Authlogic::TestCase

FactoryGirl.find_definitions

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  include FactoryGirl::Syntax::Methods
end

class ActionDispatch::IntegrationTest
  include RequestSignatureTestHelper

  def get_with_signature(path)
    self.host = "example.org"
    get_without_signature(path, {}, rack_auth_for_get(path))
  end

  def post_with_signature(path, req_params)
    self.host = "example.org"
    headers = rack_auth_for_post(path, req_params)
    headers.merge!({'CONTENT_TYPE' => 'application/json'})
    post_without_signature(path, req_params.to_json, headers)
  end

  def put_with_signature(path, req_params)
    self.host = "example.org"
    headers = rack_auth_for_put(path, req_params)
    headers.merge!({'CONTENT_TYPE' => 'application/json'})
    put_without_signature(path, req_params.to_json, headers)
  end

  alias_method_chain :get, :signature
  alias_method_chain :post, :signature
  alias_method_chain :put, :signature

  def create_subscribed_user_for(app)
    user = create(:user, :developer => app.developer)
    create(:subscription, :user => user, :app => app)
    user
  end

  def random_alphanumeric(n)
    Array.new(n){[*'0'..'9', *'a'..'z', *'A'..'Z'].sample}.join
  end
end

Turn.config do |c|
 c.format  = :outline  # :progress
end
