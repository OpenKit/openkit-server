module Dashboard
class AchievementsController < ApplicationController
  before_filter :set_app

  def index
    @achievements = @app.achievements
  end

  def show
    @achievement = @app.achievements.find(params[:id].to_i)
    @achievement_scores = @achievement.best_scores
    ActiveRecord::Associations::Preloader.new(@achievement_scores, [:user]).run
  end

  def new
    @achievement = @app.achievements.build
  end

  def edit
    @achievement = @app.achievements.find(params[:id].to_i)
  end

  def create
    @achievement = @app.achievements.new(params[:achievement])

    if @achievement.save
      redirect_to [@app, @achievement], notice: 'Achievement was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    params[:achievement].delete(:app_id)
    @achievement = @app.achievements.find(params[:id].to_i)

    if @achievement.update_attributes(params[:achievement])
      redirect_to [@app, @achievement], notice: 'Achievement was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @achievement = @app.achievements.find_by_id(params[:id].to_i)
    if @achievement
      @achievement.destroy
      notice = "Destroyed achievement."
    else
      notice = "Achievement doesn't exist."
    end
    redirect_to app_achievements_url(@app), notice: notice
  end
end
end
