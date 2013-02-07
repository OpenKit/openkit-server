# Interface:
# user.apps
# user.developer
class User < ActiveRecord::Base
  attr_accessible :nick, :fb_id, :twitter_id
  attr_accessor :cloud_data
  validates_presence_of :nick

  has_many :scores, :dependent => :delete_all
  has_many :subscriptions
  has_many :apps, :through => :subscriptions
  belongs_to :developer

end
