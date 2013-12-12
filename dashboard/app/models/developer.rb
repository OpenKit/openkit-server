

Developer.class_eval do 
  # Remove the deliver message when using Delayed Job 3. See:
  # https://github.com/collectiveidea/delayed_job
  def authorized_to_delete_score?(score)
    score.leaderboard.app.developer == self
  end

  def authorized_to_delete_achievement_score?(achievement_score)
    achievement_score.achievement.app.developer == self
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    DeveloperMailer.delay.password_reset_instructions(self)
  end
end
