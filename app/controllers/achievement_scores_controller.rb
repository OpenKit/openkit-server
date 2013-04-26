class AchievementScoresController < ApplicationController
  # From the API, we need an app_key and achievement_id for all actions
  # in this controller.  The only action that will be available from the
  # developer dashboard is destroy.
  before_filter :require_dashboard_access, :only   => [:destroy]
  before_filter :require_api_access,       :except => [:destroy]
  before_filter :set_achievement,          :except => [:destroy]

  # GET /achievement_scores
  # GET /achievement_scores.json
  def index
    since = params[:since] && Time.parse(params[:since].to_s)
    user_id = params[:user_id].to_i
    @achievement_scores = @achievement.achievement_list(user_id)
    ActiveRecord::Associations::Preloader.new(@achievement_scores, [:user]).run

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @achievement_scores.to_json(:include => :user, :methods => :rank) }
    end
  end
  
  # GET /achievement_scores/1
  # GET /achievement_scores/1.json
  def show
    @achievement_score = @achievement.achievement_scores.find(params[:id].to_i)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @achievement_score }
    end
  end

  # POST /achievement_scores
  # POST /achievement_scores.json
  def create
    err_message = nil
    user_id = params[:achievement_score].delete(:user_id)
    err_message = "Please pass a user_id with your achievement_score."  if user_id.blank?

    if !err_message
      user = user_id && current_app.users.find_by_id(user_id.to_i)
    end

    err_message = "User with that ID is not subscribed to this app."  if !user
    if !err_message
      value = params[:achievement_score].delete(:value)
      @achievement_score = @achievement.achievement_scores.build(params[:achievement_score])
      @achievement_score.value = value
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

  # DELETE /achievement_scores/1
  # DELETE /achievement_scores/1.json
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
      @achievement = current_app.achievements.find_by_id(achievement_id.to_i)
    end

    unless @achievement
      render status: :forbidden, json: {message: "Pass a achievement_id that belongs to the app associated with app_key"}
    end
  end
end
