class ScoresController < ApplicationController
  # From the API, we need an app_key and leaderboard_id for all actions
  # in this controller.  The only action that will be available from the
  # developer dashboard is destroy.
  before_filter :require_dashboard_access, :only   => [:destroy]
  before_filter :require_api_access,       :except => [:destroy]
  before_filter :set_leaderboard,          :except => [:destroy]

  # GET /scores
  # GET /scores.json
  def index
    since = params[:since] && Time.parse(params[:since].to_s)
    user_id = params[:user_id].to_i
    @scores = @leaderboard.top_scores_with_users_best(user_id, since)
    ActiveRecord::Associations::Preloader.new(@scores, [:user]).run

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @scores.to_json(:include => :user, :methods => :rank) }
    end
  end

  # GET /scores/1
  # GET /scores/1.json
  def show
    @score = @leaderboard.scores.find(params[:id].to_i)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @score }
    end
  end

  # POST /scores
  # POST /scores.json
  def create
    err_message = nil
    user_id = params[:score].delete(:user_id)
    err_message = "Please pass a user_id with your score."  if user_id.blank?

    if !err_message
      user = user_id && current_app.users.find_by_id(user_id.to_i)
    end

    err_message = "User with that ID is not subscribed to this app."  if !user

    if !err_message
      @score = @leaderboard.scores.build(params[:score])
      @score.user = user
      if !@score.save
        err_message = "Score could not be created"
      end
    end

    if !err_message
      render status: :created, json: @score, location: @score
    else
      render status: :bad_request, json: {message: err_message}
    end
  end

  # DELETE /scores/1
  # DELETE /scores/1.json
  def destroy
    @score = Score.find(params[:id].to_i)
    if current_developer.authorized_to_delete_score?(@score)
      @score.destroy
      redirect_to scores_url, notice: "Score was deleted."
    else
      redirect_to root_url, notice: "You can't delete that score."
    end
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
