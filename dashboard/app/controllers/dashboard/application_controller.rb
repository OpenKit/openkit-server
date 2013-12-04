module Dashboard
class ApplicationController < ActionController::Base
  layout 'application'
  protect_from_forgery
  before_filter :require_login
  helper_method :current_developer

  private
  def current_developer_session
    return @current_developer_session if defined?(@current_developer_session)
    @current_developer_session = DeveloperSession.find
  end

  def current_developer
    return @current_developer if defined?(@current_developer)
    @current_developer = current_developer_session && current_developer_session.record
  end

  def require_login
    unless current_developer
      store_location
      if request.path == "/"
        redirect_to login_path
      else
        redirect_to login_path, notice: "You must be logged in to do that"
      end
    end
  end

  def store_location
    session[:return_to] = request.path
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def request_base_uri
    request.protocol + request.host_with_port
  end

  def set_app
    @app = params[:app_id] && current_developer.apps.friendly.find(params[:app_id].to_s)  # to_s because we use slug on app
    if !@app
      render :status => :forbidden, :text => "Forbidden"
    end
  end
end
end
