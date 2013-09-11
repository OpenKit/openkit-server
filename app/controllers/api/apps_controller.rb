class AppsController < ApplicationController
  before_filter :require_dashboard_access,  :except => [:purge_test_data]
  before_filter :require_api_access,        :only   => [:purge_test_data]

  # GET /apps
  # GET /apps.json
  def index
    @apps = current_developer.apps

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @apps }
    end
  end

  # GET /apps/1
  # GET /apps/1.json
  def show
    @app = current_developer.apps.find(params[:id].to_s)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @app }
    end
  end

  # GET /apps/new
  # GET /apps/new.json
  def new
    @app = current_developer.apps.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @app }
    end
  end

  # GET /apps/1/edit
  def edit
    @app = current_developer.apps.find(params[:id].to_s)
  end

  # POST /apps
  # POST /apps.json
  def create
    params[:app].delete :developer_id
    @app = current_developer.apps.build(params[:app])

    respond_to do |format|
      if @app.save
        format.html { redirect_to @app, notice: 'App was successfully created.' }
        format.json { render json: @app, status: :created, location: @app }
      else
        format.html { render action: "new" }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /apps/1
  # PUT /apps/1.json
  def update
    @app = current_developer.apps.find(params[:id].to_s)

    respond_to do |format|
      if @app.update_attributes(params[:app])
        format.html { redirect_to @app, notice: 'App was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /apps/1
  # DELETE /apps/1.json
  def destroy
    @app = current_developer.apps.find(params[:id].to_s)
    @app.destroy

    respond_to do |format|
      format.html { redirect_to apps_url }
      format.json { head :no_content }
    end
  end

  def purge_test_data
    test_app = App.find_by_app_key("end_to_end_test")
    if test_app
      test_app.leaderboards.destroy_all
      test_app.achievements.destroy_all
      render json: %|{"ok":true}|
    else
      render json: %|{"ok":false}|
    end
  end
end
