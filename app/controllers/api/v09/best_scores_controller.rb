module Api::V09
class BestScoresController < ApplicationController
  before_filter :set_leaderboard

  # Note:
  # The overriden method User#as_json does not get called when ':include => :user'
  # is passed to Score#as_json.
  def index
    x = params.delete(:page_num)
    y = params.delete(:num_per_page)
    @scores = Score.bests_for(params[:leaderboard_range], @leaderboard.id, {page_num: x, num_per_page: y})
    ActiveRecord::Associations::Preloader.new(@scores, [:user]).run
    json_arr = @scores.as_json
    json_arr.each do |j|
      if j[:user]
         j[:user]['fb_id']      = j[:user]['fb_id'].to_i       if j[:user]['fb_id']
         j[:user]['google_id']  = j[:user]['google_id'].to_i   if j[:user]['google_id']
         j[:user]['twitter_id'] = j[:user]['twitter_id'].to_i  if j[:user]['twitter_id']
         j[:user]['custom_id']  = j[:user]['custom_id'].to_i   if j[:user]['custom_id']
      end 
    end
    render json: json_arr
  end

  def user
    @score = Score.best_for(params[:leaderboard_range], @leaderboard.id, params[:user_id])
    ActiveRecord::Associations::Preloader.new(@score, [:user]).run
    j = @score.as_json
    if !j.blank?
      if j[:user]
         j[:user]['fb_id']      = j[:user]['fb_id'].to_i       if j[:user]['fb_id']
         j[:user]['google_id']  = j[:user]['google_id'].to_i   if j[:user]['google_id']
         j[:user]['twitter_id'] = j[:user]['twitter_id'].to_i  if j[:user]['twitter_id']
         j[:user]['custom_id']  = j[:user]['custom_id'].to_i   if j[:user]['custom_id']
      end
    end
    render json: j
  end

  def social
    @scores = params[:fb_friends] && Score.social(authorized_app, @leaderboard, params[:fb_friends]) || []
    json_arr = @scores.as_json
    json_arr.each do |j|
      if j[:user]
         j[:user]['fb_id']      = j[:user]['fb_id'].to_i       if j[:user]['fb_id']
         j[:user]['google_id']  = j[:user]['google_id'].to_i   if j[:user]['google_id']
         j[:user]['twitter_id'] = j[:user]['twitter_id'].to_i  if j[:user]['twitter_id']
         j[:user]['custom_id']  = j[:user]['custom_id'].to_i   if j[:user]['custom_id']
      end 
    end
    render json: json_arr
  end

  private
  def set_leaderboard
    @leaderboard = authorized_app.leaderboards.find_by_id(params.delete(:leaderboard_id))
    unless @leaderboard
      render status: :forbidden, json: {message: "Pass a leaderboard_id that belongs to the app associated with app_key"}
    end
  end
end
end