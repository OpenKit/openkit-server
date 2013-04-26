class Leaderboard < ActiveRecord::Base
  attr_accessible :name, :icon, :in_development, :sort_type
  attr_accessible :type
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :app_id

  belongs_to :app
  has_many :scores

  def api_fields(base_uri = "http://localhost:3000/")
    {
      :id => id,
      :app_id => app_id,
      :name => name,
      :created_at => created_at,
      :updated_at => updated_at,
      :in_development => in_development,
      :sort_type => sort_type,
      :icon_url => base_uri + icon.url,
      :player_count => player_count
    }
  end

  # Don't store HighValueLeaderboard and LowValueLeaderboard images in different places.
  ATTACHMENT_URL = "/system/leaderboards/:attachment/:id_partition/:style/:filename"
  has_attached_file :icon, url: ATTACHMENT_URL, :default_url => '/assets/leaderboard_icon.png'

  HIGH_VALUE_SORT_TYPE = "HighValue"
  LOW_VALUE_SORT_TYPE = "LowValue"


  public

  def is_high_value?
    sort_type == HIGH_VALUE_SORT_TYPE
  end

  def is_low_value?
    sort_type == LOW_VALUE_SORT_TYPE
  end

  def player_count
    scores.count(:user_id, :distinct => true)
  end

  # Deprecated!
  def top_scores(since = nil)
    top_n_scores(5, 0, since)
  end

  # Deprecated!
  # Damn, if we have a better way to set rank this would be chainable :/
  def top_n_scores(n, offset, since)
    since = Time.now - 10.years if since.nil?
    x = Score.where(["leaderboard_id = ? AND created_at > ?", id, since]).order("sort_value #{order_keyword}").offset(offset).take(n)
    x.each_with_index {|score, i| score.rank = i + 1}
  end

  # Deprecated!
  def top_score_for_user(user_id, since = nil)
    Score.where(:leaderboard_id => id, :user_id => user_id)
    score = scores.where({:user_id => user_id}).since(since).order("sort_value #{order_keyword}").first(:include => :user)
    if score
      table = Arel::Table.new(:scores)
      order = (sort_type == HIGH_VALUE_SORT_TYPE) ? table[:sort_value].desc : table[:sort_value]
      sub = table.project("*")
      sub.where(table["leaderboard_id"].eq(id))
      sub.where(table["created_at"].gteq(since))  if since
      if sort_type == HIGH_VALUE_SORT_TYPE
        sub.where(table["sort_value"].gt(score.value))
        sub.order(table["sort_value"].desc)
      else
        sub.where(table["sort_value"].lt(score.value))
        sub.order(table["sort_value"])
      end
      sub = sub.as("sub")
      sub2 = Score.select("*").from(sub).group(:user_id).as("sub2")
      score.rank = Score.select('*').from(sub2).count + 1
    end
    score
  end

  # Deprecated!
  def top_scores_with_users_best(user_id, since = nil)
    top = top_scores(since)
    unless top.map(&:user_id).include?(user_id)
      x = top_score_for_user(user_id, since)
      top << x if x
    end
    top
  end

  private
  def extrema_func_name
    sql_lookup[sort_type][:extrema_func_name]
  end

  def order_keyword
    sql_lookup[sort_type][:order_keyword]
  end

  def sql_lookup
    @sql_lookup ||= {
      HIGH_VALUE_SORT_TYPE => {
        :extrema_func_name => "MAX",
        :order_keyword => "DESC",
      },
      LOW_VALUE_SORT_TYPE => {
        :extrema_func_name => "MIN",
        :order_keyword => "ASC",
      }
    }
  end
end
