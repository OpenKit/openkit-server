class Achievement < ActiveRecord::Base
  attr_accessible :name, :desc, :icon, :icon_locked, :in_development, :points, :goal
  attr_accessible :type
  #attr_accessor :user_id
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :app_id

  belongs_to :app
  has_many :achievement_scores, :dependent => :delete_all

  def api_fields(base_uri, user_id = nil)
    fields = {
      :id => id,
      :app_id => app_id,
      :name => name,
      :desc => desc,
      :points => points,
      :goal => goal,
      :created_at => created_at,
      :updated_at => updated_at,
      :in_development => in_development,
      :icon_url => PaperclipHelper.uri_for(icon, base_uri),
      :icon_locked_url => PaperclipHelper.uri_for(icon_locked, base_uri)
    }
    fields[:progress] = progress(user_id) if user_id
    fields
  end

  has_attached_file :icon,        :default_url => '/assets/achievement_icon.png'
  has_attached_file :icon_locked, :default_url => '/assets/achievement_locked_icon.png'


  def progress(user_id)
    res = achievement_scores.where(:user_id => user_id).order("progress DESC").limit(1)[0]
    res ? res.progress : 0
  end

  def best_scores
    cond = ActiveRecord::Base.send(:sanitize_sql_array, ["achievement_id = ?", id])

    query =<<-END
    select achievement_scores.* from (
      select t1.*, min(created_at) as first_time from (
        select achievement_id, user_id, max(progress) as max_progress from achievement_scores
        where #{cond}
        group by user_id
        order by max_progress DESC
        limit 10
      ) t1
      left join achievement_scores x on t1.achievement_id=x.achievement_id and t1.user_id=x.user_id and t1.max_progress=x.progress
      where x.#{cond}
      group by x.user_id
      ) t2
    left join achievement_scores on t2.achievement_id=achievement_scores.achievement_id AND t2.user_id=achievement_scores.user_id AND t2.max_progress=achievement_scores.progress AND t2.first_time=achievement_scores.created_at
    GROUP BY user_id
    ORDER BY achievement_scores.progress DESC
    END
    query.gsub!(/\s+/, " ")
    AchievementScore.find_by_sql(query)
  end

end
