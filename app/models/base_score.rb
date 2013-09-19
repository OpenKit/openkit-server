module BaseScore
  ENABLE_USER_RANK = true
  
  DEFAULT_JSON_PROPS = [
      :id,
      :leaderboard_id,
      :user_id,
      :value,
      :display_string,
      :metadata,
      :created_at
  ]
  DEFAULT_JSON_METHODS = [
    :value,
    :meta_doc_url,
    :is_users_best
  ]
  DEFAULT_JSON_INCLUDES = [
    :user,
    :leaderboard
  ]

  def self.included(base)
    base.belongs_to :user
    base.belongs_to :leaderboard
    base.attr_accessible :metadata, :display_string, :user_id, :meta_doc
    base.send(:attr_accessor, :rank)
    base.has_attached_file :meta_doc

    base.send :extend,  ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
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
      raise ArgumentError.new("ScoreBase#social takes an array of fb_friends.") unless fb_friends.is_a?(Array)
      return [] if fb_friends.empty?

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
        if ENABLE_USER_RANK
          rank_cond = ["leaderboard_id = ?", leaderboard_id]
          if since
            rank_cond[0] << " AND created_at > ?"
            rank_cond << since
          end
          rank_cond[0] << " AND sort_value > ?"
          rank_cond << best_score.sort_value
          sanitized_rank_cond = ActiveRecord::Base.send(:sanitize_sql_array, rank_cond)
          best_score.rank = connection.execute("select count(*) from (select * from #{table_name} where #{sanitized_rank_cond} group by user_id) t").first[0] + 1
        end
      end

      best_score
    end

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
      select #{table_name}.* from (
        select t1.*, min(created_at) as first_time from (
          select leaderboard_id, user_id, max(sort_value) as max_val from #{table_name}
          where #{leaderboard_cond} #{created_cond ? "AND " + created_cond : ''}
          group by user_id
          order by max_val DESC
          limit #{num_per_page.to_i}
          offset #{(page_num.to_i - 1) * num_per_page.to_i}
        ) t1
        left join #{table_name} x on t1.leaderboard_id=x.leaderboard_id and t1.user_id=x.user_id and t1.max_val=x.sort_value
        where x.#{leaderboard_cond} #{created_cond ? "AND x." + created_cond : ''}
        group by x.user_id
      ) t2
      left join #{table_name} on t2.leaderboard_id=#{table_name}.leaderboard_id AND t2.user_id=#{table_name}.user_id AND t2.max_val=#{table_name}.sort_value AND t2.first_time=#{table_name}.created_at
      GROUP BY user_id
      ORDER BY #{table_name}.sort_value DESC
      END

      query.gsub!(/\s+/, " ")
      scores = find_by_sql(query)
      start_rank = ((page_num - 1) * num_per_page) + 1
      scores.inject(start_rank) {|x,y| y.rank = x; x+=1; x}
      scores
    end
  end


  module InstanceMethods
    # If 'only' is passed, skip defaults and pass off to super.  This is a least
    # surprises implementation.
    #
    # Automatically include rank only if we already have it.
    def as_json(opts = {})
      if opts[:only]
        return super(opts)
      end
      includes = DEFAULT_JSON_INCLUDES | (opts[:include] || [])
      methods  = DEFAULT_JSON_METHODS  | (opts[:methods] || [])
      methods << :rank if rank
      super(:only => DEFAULT_JSON_PROPS, :methods => methods, :include => includes)
    end
    
    def value=(v)
      self.sort_value = v
      self.sort_value *= -1 if leaderboard.is_low_value?
      v
    end

    def value
      v = sort_value
      v *= -1 if leaderboard.is_low_value?
      v
    end
    
    def is_better_than?(other_score)
      sort_value > other_score.sort_value
    end

    def meta_doc_url
      meta_doc_file_name && meta_doc.url
    end

    # index_scores_composite_2
    def is_users_best
      !self.class.find(:first, :conditions => ["leaderboard_id = ? AND user_id = ? AND sort_value > ? ", leaderboard_id, user_id, sort_value])
    end
  end
end
