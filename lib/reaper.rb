class Reaper
  class << self
    def reap
      t1 = Time.now - 1.day
      t7 = Time.now - 1.week
      BestScore1.destroy_all(["created_at < ?", t1.utc])
      BestScore7.destroy_all(["created_at < ?", t7.utc])
    end
  end
end

