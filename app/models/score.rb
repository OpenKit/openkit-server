class Score < ActiveRecord::Base
  belongs_to :user
  belongs_to :leaderboard
  attr_accessible :value
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
    def create_dummy1
      s = new(:leaderboard_id => 1, :user_id => 1, :value => 100.0)
      handle_new_score(s)
      s
    end
    
    def create_dummy2
      s = new(:leaderboard_id => 1, :user_id => 1, :value => 110.0)
      handle_new_score(s)
      s
    end
    
    def create_dummy3
      s = new(:leaderboard_id => 1, :user_id => 1, :value => 90.0)
      handle_new_score(s)
      s
    end
    
    def create_dummy4
      s = new(:leaderboard_id => 1, :user_id => 1, :value => 130.0)
      handle_new_score(s)
      s
    end
    
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

