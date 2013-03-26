module BestScoreBase
  MAX_SCORE_COUNT = 3
  
  # Indices for cache.
  SCORE_COUNT     = 0
  MIN_VALUE       = 1
  MIN_VALUE_DIRTY = 2
  
  def self.included(base)
    base.attr_accessible :leaderboard_id, :user_id, :value, :score_id
    base.after_destroy :update_cache_after_destroy
    base.send :extend,  ClassMethods
    base.send :include, InstanceMethods
  end
  
  module ClassMethods
    
    # This hash lives in memory now, but should move to redis so we don't have to refresh
    # when rails starts. The format of this hash is: leaderboard_id => [count, min, min_dirty].  
    def cache
      @cache ||= {}
    end
    
    def refresh_cache_all
      arr = select("leaderboard_id, min(value) as min_val, count(*) as score_count").group(:leaderboard_id)
      arr.each do |x|
        cache[x.leaderboard_id] = [x.score_count, x.min_val, false]
      end
      cache
    end
    
    def refresh_cache(leaderboard_id)
      x = select("min(value) as min_val, count(*) as score_count").where(:leaderboard_id => leaderboard_id)[0]
      cache[leaderboard_id] = [x.score_count, x.min_val, false]
      cache[leaderboard_id]
    end
    
    def delete_all(*args)
      raise StandardError.new("You're breaking the cached record count!")
    end
    
    def create_from_score(score)
      l_id = score.leaderboard_id
      c = cache[l_id] || refresh_cache(l_id)
      if create(leaderboard_id: l_id, user_id: score.user_id, score_id: score.id, value: score.value)
        # If minimum isn't dirty, we know exactly what the minimum is.  The new score may be lower than
        # the current minimum, how?  Because the reaper kills scores that are no longer valid (out of 
        # time range), and when that happens we stuff the next scores automatically into the best table
        # until we hit a count of MAX_SCORE_COUNT.
        if !c[MIN_VALUE_DIRTY]
          if c[MIN_VALUE].nil? || (score.value < c[MIN_VALUE])
            c[MIN_VALUE] = score.value
          end
        end
        
        # If score count is over the max, kill everything with the MIN_VALUE
        if ((c[SCORE_COUNT] += 1) > MAX_SCORE_COUNT)
          destroy_all(["leaderboard_id = ? AND value = ?", l_id, c[MIN_VALUE]])
        end
      end
    end
    
    def handle(score)
      l_id = score.leaderboard_id
      c = cache[l_id] || refresh_cache(l_id)

      if c[SCORE_COUNT] < MAX_SCORE_COUNT
        create_from_score(score)
      else
        if c[MIN_VALUE_DIRTY]
          c = refresh_cache(l_id)
        end
        
        if c[MIN_VALUE].nil? || score.value > c[MIN_VALUE]
          create_from_score(score)
        end
      end
    end
  end
  
  module InstanceMethods
    def delete
      raise StandardError.new("You're breaking the cached record count!")
    end
    
    def update_cache_after_destroy
      c = self.class.cache[self.leaderboard_id]
      if !c[MIN_VALUE_DIRTY]  # not dirty
        if value == c[MIN_VALUE]
          c[MIN_VALUE_DIRTY] = true
        end
      end
      c[SCORE_COUNT] -= 1
      nil
    end
  end
end
