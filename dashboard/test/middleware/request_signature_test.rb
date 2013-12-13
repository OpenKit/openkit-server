require 'test_helper'

class RequestSignatures
  def initialize(app)
    @app = app
  end

  def call(env)
    env['app_key'] = "sup"
    @app.call(env)
  end
end

GunRack = Rack::Builder.app do
  use RequestSignatures
  run -> env do
    body = env['app_key']
    [200, {}, [body]]
  end
end


class TestApp < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    GunRack
  end

  def test_sets_app_key
    get '/'
    assert last_response.ok?
    assert last_response.body == "sup"
  end
end
