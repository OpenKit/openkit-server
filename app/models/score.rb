class Score < ActiveRecord::Base
  belongs_to :user
  belongs_to :leaderboard
  attr_accessible :value
  attr_accessor :rank

  @@max_best = 100
  @@auto_insert_threshold = 80

  module Scopes
    def since(t = nil)
      t ? where("updated_at >= :updated_at", {:updated_at => t}) : scoped
    end
  end
  extend Scopes

  class << self
    def handle_new_score(score)
      # Save in scores table
      score.save

      # Handle best scores
      if BestScore1.cached_count <= @@max_best

      end

      if score.value > BestScore1.minimum
        BestScore1.create_from_score(score)
        if BestScore1.count >
      end
    end
  end

  def is_better_than?(other_score)
    (leaderboard.is_high_value? && value > other_score.value) ||
    (leaderboard.is_low_value? && value < other_score.value)
  end

  private

end

