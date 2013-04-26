class AchievementScore < ActiveRecord::Base
  belongs_to :user
  belongs_to :achievement
  attr_accessible :metadata, :display_string, :user_id
  attr_accessor :rank
  
  @@enable_user_rank = true
  
  
  def value=(v)
    self.progress = v
    v
  end
  
  def value
    v = progress
    v
  end

  class << self

end
end

