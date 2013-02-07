class DeveloperSessionsController < ApplicationController
  before_filter :require_dashboard_access, :except => [:new, :create]

  # GET /developer_sessions/new
  def new
    @developer_session = DeveloperSession.new
  end

  # POST /developer_sessions
  def create
    @developer_session = DeveloperSession.new(params[:developer_session])
    if @developer_session.save
      flash[:notice] = "Login successful!"
      redirect_back_or_default root_url
    else
      render :action => :new
    end
  end

  # DELETE /developer_sessions/1
  def destroy
    current_developer_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_to root_url
  end
end
