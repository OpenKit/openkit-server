class Leaderboard < ActiveRecord::Base
  attr_accessible :name, :icon, :sort_type, :gamecenter_id, :gpg_id, :priority, :tag_list
  attr_accessible :type
  validates_presence_of :name, :sort_type
  validates_uniqueness_of :name, :scope => :app_id
  acts_as_taggable

  belongs_to :app
  has_many :scores, :dependent => :delete_all
  has_many :sandbox_scores, :dependent => :delete_all

  def api_fields(base_uri, sandbox)
    {
      :id => id,
      :app_id => app_id,
      :name => name,
      :created_at => created_at,
      :updated_at => updated_at,
      :sort_type => sort_type,
      :icon_url => PaperclipHelper.uri_for(icon, base_uri),
      :player_count => player_count(sandbox),
      :gamecenter_id => gamecenter_id,
      :gpg_id => gpg_id
    }
  end

  has_attached_file :icon, :default_url => 'https://ok-shared.s3-us-west-2.amazonaws.com/leaderboard_icon.png'

  HIGH_VALUE_SORT_TYPE = "HighValue"
  LOW_VALUE_SORT_TYPE = "LowValue"


  public
  def is_high_value?
    sort_type == HIGH_VALUE_SORT_TYPE
  end

  def is_low_value?
    sort_type == LOW_VALUE_SORT_TYPE
  end

  def player_count(sandbox)
    k = sandbox ? "leaderboard:#{id}:sandbox_players" : "leaderboard:#{id}:players"
    OKRedis.scard(k)
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
