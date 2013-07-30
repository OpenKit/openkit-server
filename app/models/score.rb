class Score < ActiveRecord::Base
  belongs_to :user
  belongs_to :leaderboard
  attr_accessible :metadata, :display_string, :user_id
  attr_accessor :rank

  @@enable_user_rank = true


  def value=(v)
    self.sort_value = v
    self.sort_value *= -1 if leaderboard && leaderboard.is_low_value?
    v
  end

  def value
    v = sort_value
    v *= -1 if leaderboard && leaderboard.is_low_value?
    v
  end

  module Scopes
    def since(t = nil)
      t ? where("created_at >= :created_at", {:created_at => t}) : scoped
    end
  end
  extend Scopes

  class << self

    # Apply something here that makes the time switch only every 10 minutes or so to help
    # caching.
    def time_boundary_for_frame(frame)
      boundary = case frame
        when 'today' then Time.now - 1.day
        when 'this_week' then Time.now - 1.week
        when 'all_time' then nil
      end
      boundary
    end

    def social(app, leaderboard, fb_friends)
      # Work for now.  Disable rank!!  Pass leaderboard obj instead of id!
      bests = []
      users = app.developer.users.where(:fb_id => fb_friends)
      users.each {|u|
        if (score = best_for('all_time', leaderboard.id, u.id))
          bests << score
        end
      }
      bests
    end

    def best_for(frame, leaderboard_id, user_id)
      best_cond = ["leaderboard_id = ? AND user_id = ?", leaderboard_id, user_id]

      since = time_boundary_for_frame(frame)
      if since
        best_cond[0] << " AND created_at > ?"
        best_cond << since
      end
      best_score = where(best_cond).order("sort_value DESC").limit(1)[0]

      if best_score
        if @@enable_user_rank
          rank_cond = ["leaderboard_id = ?", leaderboard_id]
          if since
            rank_cond[0] << " AND created_at > ?"
            rank_cond << since
          end
          rank_cond[0] << " AND sort_value > ?"
          rank_cond << best_score.sort_value
          sanitized_rank_cond = ActiveRecord::Base.send(:sanitize_sql_array, rank_cond)
          records = connection.execute("select count(*) from (select user_id from scores where #{sanitized_rank_cond} group by user_id) t")
          if records && (count_record = records.first)
            best_score.rank = count_record["count"].to_i + 1
          end
        end
      end

      best_score
    end

    # Cap number per page at 25 for now.
    def bests_for(frame, leaderboard_id, opts = {})
      page_num     = (opts[:page_num] && opts[:page_num].to_i) || 1
      num_per_page = (opts[:num_per_page] && opts[:num_per_page].to_i) || 25
      num_per_page > 25 && num_per_page = 25

      since = case frame
        when 'today' then Time.now - 1.day
        when 'this_week' then Time.now - 1.week
        when 'all_time' then nil
      end

      leaderboard_cond = ActiveRecord::Base.send(:sanitize_sql_array, ["leaderboard_id = ?", leaderboard_id])
      created_cond = since && ActiveRecord::Base.send(:sanitize_sql_array, ["created_at > ?", since])

      query =<<-END
      select * from (
        select distinct on (user_id) * from (
          select * from scores
          where #{leaderboard_cond} #{created_cond ? "AND " + created_cond : ''}
          order by sort_value desc limit 1000)
        t order by user_id, sort_value desc)
      t2
      order by sort_value desc
      limit #{num_per_page.to_i}
      offset #{(page_num.to_i - 1) * num_per_page.to_i}
      END

      query.gsub!(/\s+/, " ")
      scores = Score.find_by_sql(query)
      start_rank = ((page_num - 1) * num_per_page) + 1
      scores.inject(start_rank) {|x,y| y.rank = x; x+=1; x}
      scores
    end
  end

  def is_better_than?(other_score)
    sort_value > other_score.sort_value
  end

  private

end

