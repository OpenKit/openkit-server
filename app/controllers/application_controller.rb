class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_access
  helper_method :current_developer

  private
  def current_developer_session
    return @current_developer_session if defined?(@current_developer_session)
    @current_developer_session = DeveloperSession.find
  end

  def current_developer
    return @current_developer if defined?(@current_developer)
    @current_developer = @access[:dashboard] && @access[:dashboard][:developer]
  end

  def current_app
    return @current_app if defined?(@current_app)
    @current_app = @access[:api] && @access[:api][:app]
  end

  def require_dashboard_access
    unless current_developer
      respond_to do |format|
        format.html {
          store_location
          redirect_to login_path, notice: "You must be logged in to do that"
        }
        format.json {
          render status: :forbidden, json: { message: "This action is only available through the developer dashboard." }
        }
      end
    end
  end

  def require_api_access
    if current_app
      if !accepts_json?
        render status: :bad_request, json: {message: %(Client must accept JSON.  Set the 'Accepts' header on your HTTP request to "application/json")}
      end
    else
      respond_to do |format|
        format.html {
          render status: :forbidden, text: "Requires API Access"
        }
        format.json {
          message = params[:app_key] ? "Could not find an app by that app_key."
                                     : "Please pass an app_key with your request."
          render status: :forbidden, json: {message: message}
        }
      end
    end
  end

  def require_dashboard_or_api_access
    unless current_app || current_developer
      respond_to do |format|
        format.html {
          store_location
          redirect_to login_path, notice: "You must be logged in to do that"
        }
        format.json {
          render status: :forbidden, json: {message: "Please pass app_key with request"}
        }
      end
    end
  end

  def set_access
    @access = {}
    if params[:app_key]
      @access[:api] = {}
      @access[:api][:app] = App.find_by_app_key(params[:app_key].to_s)
    else
      @access[:dashboard] = {}
      @access[:dashboard][:developer] = current_developer_session && current_developer_session.record
    end
  end

  def api_request?
    @access[:api]
  end

  def store_location
    session[:return_to] = request.path
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def content_type_json?
    request.content_type == "application/json"
  end

  def accepts_json?
    request.accepts.include?("application/json")
  end
end
