class BestScoresController < ApplicationController
  before_filter :require_api_access
  before_filter :set_leaderboard

  def index
    klass = class_for_range(params[:leaderboard_range])
    @scores = klass.where(leaderboard_id: @leaderboard.id)
    ActiveRecord::Associations::Preloader.new(@scores, [:user]).run
    render json: @scores.to_json(:include => :user)
  end

  private
  def set_leaderboard
    @leaderboard = current_app.leaderboards.find_by_id(params.delete(:leaderboard_id))
    unless @leaderboard
      render status: :forbidden, json: {message: "Pass a leaderboard_id that belongs to the app associated with app_key"}
    end
  end

  def class_for_range(leaderboard_range)
    case leaderboard_range
    when "today"
      BestScore1
    when "this_week"
      BestScore7
    when "all_time"
      BestScore
    else
      BestScore
    end
  end
end
