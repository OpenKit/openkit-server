# Interface:
# app.users
# app.developer
class App < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, :use => :scoped, :scope => :developer_id

  attr_accessible :name, :icon

  belongs_to :developer
  has_many :leaderboards, :dependent => :destroy
  has_many :subscriptions
  has_many :users, :through => :subscriptions

  before_create :set_app_key

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :developer_id
  has_attached_file :icon, :default_url => '/assets/app_icon.png'


  # First, see if the user already exists for the developer of this app. If it
  # does, create a subscription to current_app for this user.  If it does not,
  # create both the user and the subscription.
  def find_or_create_subscribed_user(user_params)
    u = (user_params[:fb_id]      && developer.users.find_by_fb_id(user_params[:fb_id].to_i)) ||
        (user_params[:twitter_id] && developer.users.find_by_twitter_id(user_params[:twitter_id].to_i)) ||
        (user_params[:custom_id]  && developer.users.find_by_custom_id(user_params[:custom_id].to_i)) ||

    if !u
      u = developer.users.create(user_params)
    end

    if u && u.errors.count == 0
      u.apps << self unless u.apps.include?(self)
    end

    u
  end

  private
  def set_app_key
    begin
      self.app_key = ::RandomGen.alphanumeric_string(10 + (rand() * 10).ceil)
    end until App.count(:conditions => {:app_key => self.app_key}) == 0
  end
end
