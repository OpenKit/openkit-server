class AchievementScore < ActiveRecord::Base
  belongs_to :user
  belongs_to :achievement
  attr_accessible :progress
end

