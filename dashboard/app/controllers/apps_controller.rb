class AppsController < ApplicationController

  def index
    @apps = current_developer.apps
  end

  def show
    @app = current_developer.apps.friendly.find(params[:id].to_s)
  end

  def new
    @app = current_developer.apps.build
  end

  def edit
    @app = current_developer.apps.friendly.find(params[:id].to_s)
  end

  def create
    params[:app].delete :developer_id
    @app = current_developer.apps.build(params[:app])
    if @app.save
      redirect_to @app, notice: 'App was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    params[:app].delete :developer_id
    @app = current_developer.apps.friendly.find(params[:id].to_s)
    if @app.update_attributes(params[:app])
      redirect_to @app, notice: 'App was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @app = current_developer.apps.friendly.find(params[:id].to_s)
    @app.destroy
    redirect_to apps_url
  end
end
