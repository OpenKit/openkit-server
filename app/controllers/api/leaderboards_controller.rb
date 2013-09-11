class LeaderboardsController < ApplicationController
  before_filter :require_dashboard_or_api_access, :only   => [:index, :create, :show]
  before_filter :require_dashboard_access,        :except => [:index, :create, :show]
  before_filter :set_app


  def index
    if params[:tag]
      @leaderboards = @app.leaderboards.tagged_with(params[:tag].to_s).order(:priority)
    else
      @leaderboards = @app.leaderboards.order(:priority)
    end
    respond_to do |format|
      format.html
      format.json { render json: @leaderboards.map {|x| x.api_fields(request_base_uri)} }
    end
  end

  def show
    if api_request?
      err_message = nil
      lid = params[:id] && params[:id].to_i
      err_message = "You must pass a leaderboard id" unless lid

      if !err_message
        @leaderboard = @app.leaderboards.find_by_id(lid)
        err_message = "Your app does not have a leaderboard with id: #{lid}" unless @leaderboard
      end

      if !err_message
        render json: @leaderboard.api_fields(request_base_uri)
      else
        render status: :bad_request, json: {message: err_message}
      end
    else
      @leaderboard = @app.leaderboards.find(params[:id].to_i)
      @top_scores = Score.bests_for('all_time', @leaderboard.id)
      ActiveRecord::Associations::Preloader.new(@top_scores, [:user]).run
      # show.html.erb
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
