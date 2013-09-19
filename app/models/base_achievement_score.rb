module BaseAchievementScore

  def self.included(base)
    base.belongs_to :user
    base.belongs_to :achievement
    base.attr_accessible :progress
    base.send :extend,  ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
  end

  module InstanceMethods
  end
end
