class BestScoresController < ApplicationController
  # From the API, we need an app_key and leaderboard_id for all actions
  # in this controller.  The only action that will be available from the
  # developer dashboard is destroy.
  before_filter :require_api_access
  before_filter :set_leaderboard

  # GET /scores
  # GET /scores.json
  def index
    leaderboard_range = params[:leaderboard_range]
    
    case leaderboard_range
    when "today"
      @scores = BestScore1.where(leaderboard_id: @leaderboard.id)
      puts "today"
    when "this_week"
      @scores = BestScore7.where(leaderboard_id: @leaderboard.id)
      puts "this week"
    when "all_time"
      @scores = BestScore.where(leaderboard_id: @leaderboard.id)
      puts "all time"
    else
      @scores = BestScore.where(leaderboard_id: @leaderboard.id)
    end
    
    ActiveRecord::Associations::Preloader.new(@scores, [:user]).run
    render json: @scores.to_json(:include => :user)
  end

  private
  def set_leaderboard
    l_id1 = params[:score] && params[:score].delete(:leaderboard_id)
    l_id2 = params.delete(:leaderboard_id)
    if(leaderboard_id = l_id1 || l_id2)
      @leaderboard = current_app.leaderboards.find_by_id(leaderboard_id.to_i)
    end

    unless @leaderboard
      render status: :forbidden, json: {message: "Pass a leaderboard_id that belongs to the app associated with app_key"}
    end
  end
end
