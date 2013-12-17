require 'test_helper'

class LeaderboardsApiTest < ActionDispatch::IntegrationTest

  def create_leaderboard_for(app)
    app.leaderboards.create!(:name => 'foo', :sort_type => 'HighValue')
  end

  def setup
    @game = FactoryGirl.create(:app)
    OpenKit::Config.app_key    = @game.app_key
    OpenKit::Config.secret_key = @game.secret_key
  end


  def test_empty_array
    get '/leaderboards'
    assert response.success?
    assert_equal '[]', response.body
    assert_blank JSON.parse(response.body)
  end


  def test_single_leaderboard
    leaderboard = create_leaderboard_for(@game)
    get '/leaderboards'
    assert response.success?
    assert_equal 1, JSON.parse(response.body).count
  end


  def test_versioned_leaderboards
    leaderboard = create_leaderboard_for(@game)
    leaderboard.tag_list << 'v2'
    leaderboard.save

    get '/leaderboards?tag=v1'
    assert_equal 0, JSON.parse(response.body).count

    get '/leaderboards?tag=v2'
    list = JSON.parse(response.body)
    assert_equal 1, list.count
    assert_equal leaderboard.id, list[0]['id']
  end


  def test_show
    leaderboard = create_leaderboard_for(@game)
    get "/leaderboards/#{leaderboard.id}"
    leaderboard_json = JSON.parse(response.body)
    assert_equal leaderboard.id, leaderboard_json['id']
  end
end
