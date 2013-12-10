class LeaderboardsController < ApplicationController
  before_filter :set_app

  def index
    if params[:tag]
      @leaderboards = @app.leaderboards.tagged_with(params[:tag].to_s).order(:priority)
    else
      @leaderboards = @app.leaderboards.order(:priority)
    end
  end

  def show
    @leaderboard = @app.leaderboards.find(params[:id].to_i)
    score_class = params[:sandbox] ? SandboxScore : Score
    @top_scores = score_class.bests_1_0(@leaderboard.id)
    ActiveRecord::Associations::Preloader.new(@top_scores, [:user]).run
  end

  def new
    @leaderboard = @app.leaderboards.build
  end

  def edit
    @leaderboard = @app.leaderboards.find(params[:id].to_i)
  end

  def create
    @leaderboard = @app.leaderboards.new(params[:leaderboard])
    if @leaderboard.save
      redirect_to [@app, @leaderboard], notice: 'Leaderboard was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    params[:leaderboard].delete(:app_id)
    @leaderboard = @app.leaderboards.find(params[:id].to_i)
    if @leaderboard.update_attributes(params[:leaderboard])
      redirect_to [@app, @leaderboard], notice: 'Leaderboard was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @leaderboard = @app.leaderboards.find_by_id(params[:id].to_i)
    if @leaderboard
      @leaderboard.destroy
      notice = "Destroyed leaderboard."
    else
      notice = "Leaderboard doesn't exist."
    end
    redirect_to app_leaderboards_url(@app), notice: notice
  end

  def delete_sandbox_scores
    @leaderboard = @app.leaderboards.find_by_id(params[:leaderboard_id].to_i)
    if @leaderboard
      @leaderboard.sandbox_scores.delete_all
      redirect_to app_leaderboard_path(@app, @leaderboard), notice: "Deleted Sandbox Scores."
    else
      redirect_to :back, notice: "Could not find a leaderboard with that ID."
    end
  end
end
