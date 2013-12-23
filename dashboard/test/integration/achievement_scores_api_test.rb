require 'test_helper'

class AchievementScoresApiTest < ActionDispatch::IntegrationTest

  def create_json(user, achievement, progress)
    {
      achievement_score: {
          achievement_id: achievement.id,
          user_id: user.id,
          progress: progress
       }
    }
  end


  def setup
    @game = create(:app)
    @achievement = create(:achievement, :app => @game)
    @user1 = create_subscribed_user_for(@game)
    @user2 = create_subscribed_user_for(@game)
    OpenKit::Config.app_key    = @game.app_key
    OpenKit::Config.secret_key = @game.secret_key
  end


  test "create" do
    post '/achievement_scores', create_json(@user1, @achievement, 5)
    assert response.success?

    get "/achievements?user_id=#{@user1.id}"
    user_1_progress = JSON.parse(response.body)[0]['progress']
    assert_equal 5, user_1_progress
  end


  test "scores do not collide with other users" do
    post '/achievement_scores', create_json(@user1, @achievement, 5)
    get "/achievements?user_id=#{@user1.id}"
    user_1_progress = JSON.parse(response.body)[0]['progress']

    post '/achievement_scores', create_json(@user2, @achievement, 10)
    get "/achievements?user_id=#{@user2.id}"
    user_2_progress = JSON.parse(response.body)[0]['progress']

    assert_equal 5, user_1_progress
    assert_equal 10, user_2_progress
  end


  test "does not post score for achievement that does not belong to app" do
    achievement = create(:achievement)
    post '/achievement_scores', create_json(@user1, achievement, 1)
    assert response.status.between?(400, 499)
    achievement.app = @game
    achievement.save
    post '/achievement_scores', create_json(@user1, achievement, 1)
    assert response.status.between?(200, 299)
  end


  test "highest progress is used" do
    [5, 11, 7, 2].each do |val|
      post '/achievement_scores', create_json(@user1, @achievement, val)
    end
    get "/achievements?user_id=#{@user1.id}"
    user_1_progress = JSON.parse(response.body)[0]['progress']
    assert_equal 11, user_1_progress

    # Test random vals
    vals = Array.new(20) {rand(0..100)}
    max = vals.max
    vals.each do |val|
      post '/achievement_scores', create_json(@user2, @achievement, val)
    end
    get "/achievements?user_id=#{@user2.id}"
    user_2_progress = JSON.parse(response.body)[0]['progress']
    assert_equal max, user_2_progress
  end
end

