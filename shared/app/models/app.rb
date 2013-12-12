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


  def features
    if feature_list.blank?
      FeatureArray.new
    else
      FeatureArray.new(feature_list.split(',').collect(&:to_sym))
    end
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
