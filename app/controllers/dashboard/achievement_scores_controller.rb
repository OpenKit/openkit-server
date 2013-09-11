class AchievementScoresController < ApplicationController
  before_filter :require_dashboard_access, :only   => [:destroy]
  before_filter :require_api_access,       :except => [:destroy]
  before_filter :set_achievement,          :except => [:destroy]

  def create
    err_message = nil
    user_id = params[:achievement_score].delete(:user_id)
    err_message = "Please pass a user_id with your achievement_score."  if user_id.blank?

    if !err_message
      user = user_id && authorized_app.users.find_by_id(user_id.to_i)
    end

    err_message = "User with that ID is not subscribed to this app."  if !user
    if !err_message
      @achievement_score = @achievement.achievement_scores.build(params[:achievement_score])
      @achievement_score.user = user
      if !@achievement_score.save
        err_message = "#{@achievement_score.errors.full_messages.join(", ")}"
      end
    end

    if err_message
      render status: :bad_request, json: {message: err_message}
    else
      render json: @achievement_score, location: @achievement_score
    end
  end


  def destroy
    @achievement_score = AchievementScore.find(params[:id].to_i)
    if current_developer.authorized_to_delete_achievement_score?(@achievement_score)
      @achievement_score.destroy
      redirect_to achievement_scores_url, notice: "Score was deleted."
    else
      redirect_to root_url, notice: "You can't delete that score."
    end
  end

  private
  def set_achievement
    l_id1 = params[:achievement_score] && params[:achievement_score].delete(:achievement_id)
    l_id2 = params.delete(:achievement_id)
    if(achievement_id = l_id1 || l_id2)
      @achievement = authorized_app.achievements.find_by_id(achievement_id.to_i)
    end

    unless @achievement
      render status: :forbidden, json: {message: "Pass a achievement_id that belongs to the app associated with app_key"}
    end
  end
end
