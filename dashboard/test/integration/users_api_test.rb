require 'test_helper'

class UsersApiTest < ActionDispatch::IntegrationTest

  def setup
    @game        = FactoryGirl.create(:app)
    @leaderboard = FactoryGirl.create(:leaderboard, :low_value, :app => @game)
    OpenKit::Config.app_key    = @game.app_key
    OpenKit::Config.secret_key = @game.secret_key
  end

  def test_user_create
    post '/users', {user: {nick: "Lou Zell", custom_id: "123"}}
    assert response.success?
    u = JSON.parse(response.body)
    assert_kind_of Integer, u['id']
    assert_equal "123", u['custom_id']
    assert_equal "Lou Zell", u['nick']
    # TODO: make this belong_to :app instead
    assert_equal @game.developer_id, u['developer_id']
  end


  def test_user_subscribe
    post '/users', {user: {nick: "Lou Zell", custom_id: "123"}}
    u1 = JSON.parse(response.body)
    assert_not_nil u1['id']

    # Create a second app by this developer
    @game2 = FactoryGirl.create(:app, :developer => @game.developer)
    OpenKit::Config.app_key    = @game2.app_key
    OpenKit::Config.secret_key = @game2.secret_key
    post '/users', {user: {nick: "Lou Zell", custom_id: "123"}}
    u2 = JSON.parse(response.body)
    assert_equal u1['id'], u2['id'] # Same user row!

    # Create a third app by a _new_ developer
    @game3 = FactoryGirl.create(:app)
    OpenKit::Config.app_key    = @game3.app_key
    OpenKit::Config.secret_key = @game3.secret_key
    post '/users', {user: {nick: "Lou Zell", custom_id: "123"}}
    u3 = JSON.parse(response.body)
    assert_not_equal u3['id'], u1['id'] # Important!  New user row created!
  end


  def test_user_update
    post '/users', {user: {nick: "Lou Zell", custom_id: "123"}}
    u1 = JSON.parse(response.body)
    put "/users/#{u1['id']}", {nick: "Lou Z"}
    u2 = JSON.parse(response.body)
    assert_equal u1['id'], u2['id']
    assert_equal "Lou Z", u2['nick']
  end
end
