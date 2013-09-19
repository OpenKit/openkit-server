class SandboxScore < ActiveRecord::Base
  include BaseScore
  after_create :add_player_to_sandbox_set

  private
  def add_player_to_sandbox_set
    k = "leaderboard:#{leaderboard_id}:sandbox_players"
    OKRedis.connection.sadd(k, user_id)
  end
end

