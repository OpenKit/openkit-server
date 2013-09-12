# Interface:
# user.apps
# user.developer
class User < ActiveRecord::Base
  attr_accessible :nick, :fb_id, :twitter_id, :google_id, :custom_id, :gamecenter_id
  attr_accessor :cloud_data
  validates_presence_of :nick
  validate :has_service_id

  has_many :scores, :dependent => :delete_all
  has_many :subscriptions
  has_many :apps, :through => :subscriptions
  has_many :tokens
  belongs_to :developer

  class << self
    def unreferenced
      joins("left join subscriptions on subscriptions.user_id=users.id").where("subscriptions.user_id IS NULL").select("distinct users.*")
    end
  end

  private
  def has_service_id
    unless fb_id || twitter_id || google_id || custom_id || gamecenter_id
      errors.add(:base, "Please provide a service id for this user (fb_id, twitter_id, google_id, gamecenter_id, or custom_id)")
    end
  end

end
