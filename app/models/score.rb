class Score < ActiveRecord::Base
  belongs_to :user
  belongs_to :leaderboard
  attr_accessible :value
  attr_accessor :rank

  module Scopes
    def since(t = nil)
      t ? where("updated_at >= :updated_at", {:updated_at => t}) : scoped
    end
  end
  extend Scopes

  class << self
    def handle_new_score(score)
      old = Score.find_by_user_id_and_leaderboard_id(score.user_id, score.leaderboard_id)
      if old
        if score.is_better_than?(old)
          old.update_attributes(value: score.value)
          return old   # The old switcheroo
        else
          score.errors.add(:score, "is not better than previously submitted score")
          return score
        end
      else
        score.save
        return score
      end
    end
  end

  def is_better_than?(other_score)
    (leaderboard.is_high_value? && value > other_score.value) ||
    (leaderboard.is_low_value? && value < other_score.value)
  end

  private

end

