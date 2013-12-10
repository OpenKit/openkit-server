# Interface:
# app.users
# app.developer
class App < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, :use => :scoped, :scope => :developer_id

  attr_accessible :name, :icon, :fbid

  belongs_to :developer
  has_many :leaderboards, :dependent => :destroy
  has_many :achievements, :dependent => :destroy

  # This can leave users in the system that are not referenced by anything.
  # That's alright, we'll kill them with a maintenance task.
  has_many :subscriptions, :dependent => :destroy
  has_many :users, :through => :subscriptions

  before_validation :set_app_key, :on => :create
  before_validation :set_secret_key, :on => :create
  after_create :store_secret_in_redis

  validates_presence_of :name, :app_key, :secret_key
  validates_uniqueness_of :name, :scope => :developer_id
  has_attached_file :icon, :default_url => '/assets/app_icon.png'

  has_many :tokens
  has_many :sandbox_tokens



  # First, see if the user already exists for the developer of this app, based
  # on user_params. If user already exists, subscribe him/her to this app.  If
  # user does not yet exist, create both the user and the subscription.
  def find_or_create_subscribed_user(user_params)
    u = (user_params[:fb_id]      && developer.users.find_by(fb_id: user_params[:fb_id].to_s)) ||
        (user_params[:twitter_id] && developer.users.find_by(twitter_id: user_params[:twitter_id].to_s)) ||
        (user_params[:google_id]  && developer.users.find_by(google_id: user_params[:google_id].to_s))||
        (user_params[:custom_id]  && developer.users.find_by(custom_id: user_params[:custom_id].to_s)) ||
        (user_params[:gamecenter_id]  && developer.users.find_by(gamecenter_id: user_params[:gamecenter_id].to_s))

    if !u
      u = developer.users.create(user_params)
    end

    if u.errors.count == 0
      u.apps << self unless u.apps.include?(self)
    end

    u
  end

  def features
    if feature_list.blank?
      FeatureArray.new
    else
      FeatureArray.new(feature_list.split(',').collect(&:to_sym))
    end
  end

  def features=(arr)
    raise ArgumentError.new("Pass an array to App#features=") unless arr.is_a?(Array)
    self.feature_list = arr.join(',')
  end

  def sandbox_push_cert
    @sandbox_push_cert ||= SandboxPushCert.find_by_app_key(app_key)
  end

  def production_push_cert
    @production_push_cert ||= ProductionPushCert.find_by_app_key(app_key)
  end

  private
  def set_app_key
    begin
      self.app_key = OAuth::Helper.generate_key(20)[0, 20]
    end until App.where(:app_key => self.app_key).count == 0
  end

  def set_secret_key
    self.secret_key = OAuth::Helper.generate_key(40)[0, 40]
  end

  def store_secret_in_redis
    OKRedis.connection.set(secret_location, secret_key)
  end

  def remove_secret_from_redis
    OKRedis.connection.del(secret_location)
  end

  def secret_location
    "sk:#{app_key}"
  end
end
