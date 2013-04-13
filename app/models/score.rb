class Score < ActiveRecord::Base
  belongs_to :user
  belongs_to :leaderboard
  attr_accessible :value, :metadata
  attr_accessor :rank
  
  # TODO: REMOVE ME: 
  attr_accessible :leaderboard_id, :user_id

  module Scopes
    def since(t = nil)
      t ? where("updated_at >= :updated_at", {:updated_at => t}) : scoped
    end
  end
  extend Scopes

  class << self    
    def handle_new_score(score)
      if score.save
        BestScore1.handle(score)
        BestScore7.handle(score)
        BestScore.handle(score)
      end
    end
  end

  def is_better_than?(other_score)
    (leaderboard.is_high_value? && value > other_score.value) ||
    (leaderboard.is_low_value? && value < other_score.value)
  end

  private

end

