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
  has_attached_file :icon, url: ATTACHMENT_URL

  HIGH_VALUE_SORT_TYPE = "HighValue"
  LOW_VALUE_SORT_TYPE = "LowValue"


  public
  def player_count
    scores.count(:user_id, :distinct => true)
  end

  def top_scores(since = nil)
    top_n_scores(5, 0, since)
  end

  # Damn, if we have a better way to set rank this would be chainable :/
  def top_n_scores(n, offset, since)
    t1 = Arel::Table.new :scores
    t2 = Arel::Table.new :scores

    n_extreme = t2.project("leaderboard_id, user_id, #{extrema_func_name}(value) as extrema")
    n_extreme.where(t2[:leaderboard_id].eq(id))
    n_extreme.where(t2[:created_at].gteq(since)) if since
    n_extreme.group("user_id")
    n_extreme.order("extrema #{order_keyword}")
    n_extreme.take(n)
    n_extreme.skip(offset)
    n_extreme = n_extreme.as("n_extreme")

    join = Arel::Nodes::InnerJoin.new(n_extreme, Arel::Nodes::On.new(t1[:leaderboard_id].eq(n_extreme[:leaderboard_id]) \
      .and(t1[:user_id].eq(n_extreme[:user_id])) \
      .and(t1[:value].eq(n_extreme[:extrema]))))

    x = Score.select("*").joins(join)
    x.each_with_index {|score, i| score.rank = i + 1}
  end

  def top_score_for_user(user_id, since = nil)
    score = scores.where({:user_id => user_id}).since(since).order("value #{order_keyword}").first(:include => :user)
    if score
      table = Arel::Table.new(:scores)
      order = (sort_type == HIGH_VALUE_SORT_TYPE) ? table[:value].desc : table[:value]
      sub = table.project("*")
      sub.where(table["leaderboard_id"].eq(id))
      sub.where(table["created_at"].gteq(since))  if since
      if sort_type == HIGH_VALUE_SORT_TYPE
        sub.where(table["value"].gt(score.value))
        sub.order(table["value"].desc)
      else
        sub.where(table["value"].lt(score.value))
        sub.order(table["value"])
      end
      sub = sub.as("sub")
      sub2 = Score.select("*").from(sub).group(:user_id).as("sub2")
      score.rank = Score.select('*').from(sub2).count + 1
    end
    score
  end

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
