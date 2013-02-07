class Score < ActiveRecord::Base
  belongs_to :user
  belongs_to :leaderboard
  attr_accessible :value
  attr_accessor :rank

  module Scopes
    def since(t = nil)
      t ? where("created_at >= :created_at", {:created_at => t}) : scoped
    end
  end
  extend Scopes

end

