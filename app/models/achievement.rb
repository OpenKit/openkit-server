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
      :icon_url => base_uri + icon.url,
      :icon_locked_url => base_uri + icon_locked.url,
    }
    fields[:progress] = progress(user_id) if user_id
    fields
  end

  # Move to s3
  ATTACHMENT_URL = "/system/achievements/:attachment/:id_partition/:style/:filename"
  has_attached_file :icon,        url: ATTACHMENT_URL, :default_url => '/assets/achievement_icon.png'
  has_attached_file :icon_locked, url: ATTACHMENT_URL, :default_url => '/assets/achievement_locked_icon.png'


  def progress(user_id)
    res = achievement_scores.where(:user_id => user_id).order("progress DESC").limit(1)[0]
    res ? res.progress : 0
  end

  def achievement_list(user_id)
    AchievementScore.where(:achievement_id => id, :user_id => user_id)
    achievement_score = achievement_scores.where({:user_id => user_id}).first(:include => :user)
    if achievement_score
      table = Arel::Table.new(:achievement_scores)
      #order = (sort_type == HIGH_VALUE_SORT_TYPE) ? table[:value].desc : table[:value]
      sub = table.project("*")
      sub.where(table["achievement_id"].eq(id))
      sub = sub.as("sub")
      sub2 = AchievementScore.select("*").from(sub).group(:user_id).as("sub2")
      achievement_score.rank = AchievementScore.select('*').from(sub2).count + 1
    end
    achievement_score
  end

end
