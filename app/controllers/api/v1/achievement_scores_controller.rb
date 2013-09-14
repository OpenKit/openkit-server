module Api::V1
class AchievementScoresController < ApplicationController
  before_filter :set_achievement

  def create
    err_message = nil
    err_code = nil
    user_id = params[:achievement_score].delete(:user_id)
    if user_id.blank?
      err_message = "Please pass a user_id with your achievement_score."
      err_code = :bad_request
    end

    if !err_message
      user = user_id && authorized_app.users.find_by_id(user_id.to_i)
      if !user
        err_message = "User with that ID is not subscribed to this app."
        err_code = 410
      end
    end

    if !err_message
      @achievement_score = @achievement.achievement_scores.build(params[:achievement_score])
      @achievement_score.user = user
      if !@achievement_score.save
        err_message = "#{@achievement_score.errors.full_messages.join(", ")}"
        err_code = :bad_request
      end
    end

    if err_message
      render status: err_code, json: {message: err_message}
    else
      render json: @achievement_score, location: @achievement_score
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
end
