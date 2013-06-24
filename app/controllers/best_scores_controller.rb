class BestScoresController < ApplicationController
  before_filter :require_api_access
  before_filter :set_leaderboard

  def index
    x = params.delete(:page_num)
    y = params.delete(:num_per_page)
    @scores = Score.bests_for(params[:leaderboard_range], @leaderboard.id, {page_num: x, num_per_page: y})
    ActiveRecord::Associations::Preloader.new(@scores, [:user]).run
    render json: @scores.to_json(:include => :user, :methods => [:value, :rank])
  end

  def user
    @score = Score.best_for(params[:leaderboard_range], @leaderboard.id, params[:user_id])
    ActiveRecord::Associations::Preloader.new(@score, [:user]).run
    render json: @score.to_json(:include => :user, :methods => [:value, :rank])
  end

  private
  def set_leaderboard
    @leaderboard = authorized_app.leaderboards.find_by_id(params.delete(:leaderboard_id))
    unless @leaderboard
      render status: :forbidden, json: {message: "Pass a leaderboard_id that belongs to the app associated with app_key"}
    end
  end
end
