class AchievementsController < ApplicationController
  before_filter :require_dashboard_or_api_access, :only   => [:index, :facebook]
  before_filter :require_dashboard_access,        :except => [:index, :facebook]
  before_filter :set_app
  layout "facebook",    :only   => [:facebook]
  layout "application", :except => [:facebook]


  def index
    @achievements = @app.achievements
    user_id = params[:user_id] && params[:user_id].to_i
    respond_to do |format|
      format.html
      format.json {
        render json: @achievements.map {|x| x.api_fields(request_base_uri, user_id)}
      }
    end
  end


  # Dash only
  def show
    @achievement = @app.achievements.find(params[:id].to_i)
    @top_scores = Score.bests_for('all_time', @achievement.id)
    ActiveRecord::Associations::Preloader.new(@top_scores, [:user]).run

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @achievement.api_fields }
    end
  end

  # GET /achievement_scores/1
  def facebook
    #@achievements = @app.achievements
    @achievement = @app.achievements.find(params[:achievement_id].to_i)
    #@top_scores = Score.bests_for('all_time', @achievement.id)
    #ActiveRecord::Associations::Preloader.new(@top_scores, [:user]).run

    respond_to do |format|
      format.html # facebook.html.erb
      format.json { render json: @achievement.api_fields }
    end
  end


  # Dash only
  def new
    @achievement = @app.achievements.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @achievement.api_fields }
    end
  end

  # Dash only
  def edit
    @achievement = @app.achievements.find(params[:id].to_i)
  end

  # Dash only
  def create
    @achievement = @app.achievements.new(params[:achievement])

    respond_to do |format|
      if @achievement.save
        format.html { redirect_to [@app, @achievement], notice: 'Achievement was successfully created.' }
        format.json { render json: @achievement.api_fields, status: :created, location: [@app, @achievement] }
      else
        format.html { render action: "new" }
        format.json { render json: @achievement.errors, status: :unprocessable_entity }
      end
    end
  end

  # Dash only
  def update
    params[:achievement].delete(:app_id)
    @achievement = @app.achievements.find(params[:id].to_i)

    respond_to do |format|
      if @achievement.update_attributes(params[:achievement])
        format.html { redirect_to [@app, @achievement], notice: 'Achievement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @achievement.errors, status: :unprocessable_entity }
      end
    end
  end

  # Dash only
  def destroy
    @achievement = @app.achievements.find_by_id(params[:id].to_i)
    if @achievement
      @achievement.destroy
      notice = "Destroyed achievement."
    else
      notice = "Achievement doesn't exist."
    end

    respond_to do |format|
      format.html { redirect_to app_achievements_url(@app), notice: notice }
      format.json { head :no_content }
    end
  end

end
