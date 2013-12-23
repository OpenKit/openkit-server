require 'test_helper'

class ScoresApiTest < ActionDispatch::IntegrationTest

  def create_json(user, leaderboard, value)
    {
      score: {
          leaderboard_id: leaderboard.id,
          user_id: user.id,
          value: value,
          display_string: "#{value} points"
       }
    }
  end


  def submit_values(user, leaderboard, value_array)
    value_array.each do |val|
      post '/scores', create_json(user, leaderboard, val)
    end
  end


  def setup
    @game = create(:app)
    @high_value_leaderboard = create(:leaderboard, :high_value, :app => @game)
    @low_value_leaderboard = create(:leaderboard, :low_value, :app => @game)
    @user1 = create_subscribed_user_for(@game)
    @user2 = create_subscribed_user_for(@game)
    @user3 = create_subscribed_user_for(@game)
    OpenKit::Config.app_key    = @game.app_key
    OpenKit::Config.secret_key = @game.secret_key
  end


  test "create score" do
    post '/scores', create_json(@user1, @high_value_leaderboard, 100)
    assert response.success?

    get "/best_scores/user?leaderboard_id=#{@high_value_leaderboard.id}&user_id=#{@user1.id}"
    user_1_best = JSON.parse(response.body)['value']
    assert_equal 100, user_1_best
  end


  test "uses best high value score" do
    submit_values(@user1, @high_value_leaderboard, [5, 4, 9, 20, 9])
    get "/best_scores/user?leaderboard_id=#{@high_value_leaderboard.id}&user_id=#{@user1.id}"
    user_1_best = JSON.parse(response.body)['value']
    assert_equal 20, user_1_best
  end


  test "uses best low value score" do
    submit_values(@user1, @low_value_leaderboard, [5, 4, 9, 20, 9])
    get "/best_scores/user?leaderboard_id=#{@low_value_leaderboard.id}&user_id=#{@user1.id}"
    user_1_best = JSON.parse(response.body)['value']
    assert_equal 4, user_1_best
  end


  test "best scores can return empty array" do
    get "/best_scores?leaderboard_id=#{@high_value_leaderboard.id}"
    assert response.success?
    assert_equal "[]", response.body
  end


  test "best high value scores" do
    submit_values(@user1, @high_value_leaderboard, [5, 4, 9, 20, 9])
    submit_values(@user2, @high_value_leaderboard, [6, 1, 21, 21, 7])
    get "/best_scores?leaderboard_id=#{@high_value_leaderboard.id}"
    json_list = JSON.parse(response.body)
    assert_equal 2, json_list.count
    first = json_list[0]
    second = json_list[1]
    assert_equal @user2.id, first['user_id']
    assert_equal 21,        first['value']
    assert_equal @user1.id, second['user_id']
    assert_equal 20,        second['value']
  end


  test "best low value scores" do
    submit_values(@user1, @low_value_leaderboard, [5, 4, 9, 20, 9])
    submit_values(@user2, @low_value_leaderboard, [6, 1, 21, 21, 7])
    get "/best_scores?leaderboard_id=#{@low_value_leaderboard.id}"
    json_list = JSON.parse(response.body)
    assert_equal 2, json_list.count
    first = json_list[0]
    second = json_list[1]
    assert_equal @user2.id, first['user_id']
    assert_equal 1,         first['value']
    assert_equal @user1.id, second['user_id']
    assert_equal 4,         second['value']
  end


  test "pagination" do
    post '/scores', create_json(@user1, @high_value_leaderboard, 50)
    post '/scores', create_json(@user2, @high_value_leaderboard, 60)

    num_per_page = 1
    page_num = 1
    get "/best_scores?leaderboard_id=#{@high_value_leaderboard.id}&page_num=#{page_num}&num_per_page=#{num_per_page}"
    json_list = JSON.parse(response.body)
    assert_equal 1, json_list.count
    assert_equal 60, json_list[0]['value']

    num_per_page = 1
    page_num = 2
    get "/best_scores?leaderboard_id=#{@high_value_leaderboard.id}&page_num=#{page_num}&num_per_page=#{num_per_page}"
    json_list = JSON.parse(response.body)
    assert_equal 1, json_list.count
    assert_equal 50, json_list[0]['value']

    num_per_page = 2
    page_num = 1
    get "/best_scores?leaderboard_id=#{@high_value_leaderboard.id}&page_num=#{page_num}&num_per_page=#{num_per_page}"
    json_list = JSON.parse(response.body)
    assert_equal 2, json_list.count
    assert_equal 60, json_list[0]['value']
    assert_equal 50, json_list[1]['value']

    num_per_page = 2
    page_num = 2
    get "/best_scores?leaderboard_id=#{@high_value_leaderboard.id}&page_num=#{page_num}&num_per_page=#{num_per_page}"
    assert_equal "[]", response.body
  end


  test "facebook friends' scores" do
    @user1.update_attributes :fb_id => "97"
    @user2.update_attributes :fb_id => "98"
    @user3.update_attributes :fb_id => "99"

    post '/scores', create_json(@user1, @high_value_leaderboard, 50)
    post '/scores', create_json(@user2, @high_value_leaderboard, 60)
    post '/scores', create_json(@user3, @high_value_leaderboard, 70)

    # Single friend:
    post '/best_scores/social', {leaderboard_id: @high_value_leaderboard.id, user_id: @user1.id, fb_friends: [@user2.fb_id]}
    json_list = JSON.parse(response.body)
    assert_equal 1, json_list.count
    assert_equal @user2.id, json_list[0]['user_id']

    # Both friends:
    post '/best_scores/social', {leaderboard_id: @high_value_leaderboard.id, user_id: @user1.id, fb_friends: [@user2.fb_id, @user3.fb_id]}
    json_list = JSON.parse(response.body)
    assert_equal 2,          json_list.count
    assert_equal @user3.id,  json_list[0]['user_id']
    assert_equal 70,         json_list[0]['value']
    assert_equal @user2.id,  json_list[1]['user_id']
    assert_equal 60,         json_list[1]['value']
  end


  test "leaderboard must belong to app" do
    leaderboard = create(:leaderboard, :high_value)
    get "/best_scores?leaderboard_id=#{leaderboard.id}"
    assert response.status.between?(400, 499)
    @game.leaderboards << leaderboard
    get "/best_scores?leaderboard_id=#{leaderboard.id}"
    assert response.status.between?(200, 299)
  end
end
