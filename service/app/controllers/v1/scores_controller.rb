module V1
class ScoresController < ApplicationController
  before_filter :set_leaderboard

  def show
    @score = @leaderboard.send(scores_association).find(params[:id].to_i)
    render json: @score
  end

  def create
    err_message = nil
    err_code = nil
    user_id = params[:score].delete(:user_id)
    if user_id.blank?
      err_message = "Please pass a user_id with your score."
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
      value = params[:score].delete(:value)
      @score = @leaderboard.send(scores_association).build(params[:score])
      @score.value = value
      @score.user = user
      if !@score.save
        err_message = "#{@score.errors.full_messages.join(", ")}"
        err_code = :bad_request
      end
    end

    if err_message
      render status: err_code, json: {message: err_message}
    else
      render json: @score
    end
  end

  private
  def set_leaderboard
    l_id1 = params[:score] && params[:score].delete(:leaderboard_id)
    l_id2 = params.delete(:leaderboard_id)
    if(leaderboard_id = l_id1 || l_id2)
      @leaderboard = authorized_app.leaderboards.find_by_id(leaderboard_id.to_i)
    end

    unless @leaderboard
      render status: :forbidden, json: {message: "Pass a leaderboard_id that belongs to the app associated with app_key"}
    end
  end
  
  def scores_association
    in_sandbox? ? :sandbox_scores : :scores
  end
end
end
