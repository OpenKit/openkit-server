module BestScoreBase
  
  def self.included(base)
    base.attr_accessible :leaderboard_id, :user_id, :value, :score_id
    base.after_destroy :update_class_cache
    base.class_eval do 
      # This hash lives in memory now, but could be moved to redis easily.
      # The format of this hash is: leaderboard_id => [count, min, min_dirty].  
      class << self; attr_accessor :cache; end;
    end
    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
  end
  
  module ClassMethods
    def create_dummy
      create!(:leaderboard_id => 1, :user_id => 1, :score_id => 1, :value => 100.0)
    end
    
    def refresh_cache
      BestScore.select("leaderboard_id, count(*) as s_count").group(:leaderboard_id)
    end
    
    def delete_all(*args)
      raise StandardError.new("You're breaking the cached record count!")
    end
  end
  
  module InstanceMethods
    def update_class_cache
      # c = self.class.cache[self.leaderboard_id]
      # if c[2]
      #   # continue on our way.
      # else
      #   if (value - c[1]) <= 0.0000001
      #     c[2] = true
      #   end
      # end
      # c[0] -= 1
      debugger
      ''
      # raise StandardError.new("You're breaking the cached record count!")
    end
  end
end
