require 'test_helper.rb'

class ScoreApiTest < ApiTest
  def setup
    super
    @leaderboard_id = 831
    @user_id = 237492
  end

  def test_create
    custom_id = random_alphanumeric(7)
    nick = "guest-#{custom_id}"

    request = Post.new '/v1/scores', {score: {user_id: @user_id, leaderboard_id: @leaderboard_id, value: 100}}
    response = request.perform
    assert response.code =~ /^20\d/,  "Got a return code of #{response.code}"

    score = JSON.parse(response.body)
    assert score['id']
  end
end

