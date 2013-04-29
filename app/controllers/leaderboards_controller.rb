class LeaderboardsController < ApplicationController
  before_filter :require_dashboard_or_api_access, :only   => [:index]
  before_filter :require_dashboard_access,        :except => [:index]
  before_filter :set_app


  def index
    @leaderboards = @app.leaderboards
    respond_to do |format|
      format.html
      format.json { render json: @leaderboards.map {|x| x.api_fields(request_base_uri)} }
    end
  end

  # Dash only
  def show
    @leaderboard = @app.leaderboards.find(params[:id].to_i)
    @top_scores = Score.bests_for('all_time', @leaderboard.id)
    ActiveRecord::Associations::Preloader.new(@top_scores, [:user]).run

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @leaderboard.api_fields(request_base_uri) }
    end
  end

  # Dash only
  def new
    @leaderboard = @app.leaderboards.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @leaderboard.api_fields(request_base_uri) }
    end
  end

  # Dash only
  def edit
    @leaderboard = @app.leaderboards.find(params[:id].to_i)
  end

  def create
    @leaderboard = @app.leaderboards.new(params[:leaderboard])

    respond_to do |format|
      if @leaderboard.save
        format.html { redirect_to [@app, @leaderboard], notice: 'Leaderboard was successfully created.' }
        format.json { render json: @leaderboard.api_fields(request_base_uri), status: :created, location: [@app, @leaderboard] }
      else
        format.html { render action: "new" }
        format.json { render json: @leaderboard.errors, status: :unprocessable_entity }
      end
    end
  end

  # Dash only
  def update
    params[:leaderboard].delete(:app_id)
    @leaderboard = @app.leaderboards.find(params[:id].to_i)

    respond_to do |format|
      if @leaderboard.update_attributes(params[:leaderboard])
        format.html { redirect_to [@app, @leaderboard], notice: 'Leaderboard was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @leaderboard.errors, status: :unprocessable_entity }
      end
    end
  end

  # Dash only
  def destroy
    @leaderboard = @app.leaderboards.find_by_id(params[:id].to_i)
    if @leaderboard
      @leaderboard.destroy
      notice = "Destroyed leaderboard."
    else
      notice = "Leaderboard doesn't exist."
    end

    respond_to do |format|
      format.html { redirect_to app_leaderboards_url(@app), notice: notice }
      format.json { head :no_content }
    end
  end
end
