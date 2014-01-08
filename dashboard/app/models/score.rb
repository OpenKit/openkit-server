class Score < ActiveRecord::Base
  include BaseScore
  after_create :add_player_to_set

  private
  def add_player_to_set
    k = "leaderboard:#{leaderboard_id}:players"
    OKRedis.sadd(k, user_id)
  end
end

