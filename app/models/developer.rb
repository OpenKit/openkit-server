# Interface:
# developer.users
# developer.apps
class Developer < ActiveRecord::Base
  acts_as_authentic do |c|
    c.perishable_token_valid_for = 24.hours
  end
  attr_accessible :email, :password, :password_confirmation, :name

  has_many :apps, :dependent => :destroy
  has_many :users

  validates_presence_of :email
  validates_uniqueness_of :email

  def authorized_to_delete_score?(score)
    score.leaderboard.app.developer == self
  end

  def authorized_to_delete_achievement_score?(achievement_score)
    achievement_score.achievement.app.developer == self
  end

  # Remove the deliver message when using Delayed Job 3. See:
  # https://github.com/collectiveidea/delayed_job
  def deliver_password_reset_instructions!
    reset_perishable_token!
    DeveloperMailer.delay.password_reset_instructions(self)
  end

  def developer_data
    OKData.find_all_for_developer(self)
  end
end
