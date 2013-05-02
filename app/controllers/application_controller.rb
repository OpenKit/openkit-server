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

  def authorized_app
    return @authorized_app if defined?(@authorized_app)
    @authorized_app = @access[:api] && @access[:api][:app]
  end

  def require_dashboard_access
    unless current_developer
      respond_to do |format|
        format.html {
          store_location
          redirect_to login_path, notice: "You must be logged in to do that"
        }
        format.json {
          render :status => :forbidden, :json => { message: "This action is only available through the developer dashboard." }
        }
      end
    end
  end

  def require_api_access
    unless accepts_json?
      render :status => :bad_request, :text => %(Client must accept JSON.  Set the 'Accept' header on your HTTP request to "application/json")
    else
      unless authorized_app
        render :status => :forbidden, :json => { message: "Please make sure your app_key and secret_key are correct." }
      end
    end
  end

  def require_dashboard_or_api_access
    if api_request?
      unless accepts_json?
        render :status => :bad_request, :text => %(Client must accept JSON.  Set the 'Accept' header on your HTTP request to "application/json")
      else
        unless authorized_app
          render :status => :forbidden, :json => { message: "Please make sure your app_key and secret_key are correct." }
        end
      end
    else
      unless current_developer
        store_location
        redirect_to login_path, notice: "You must be logged in to do that"
      end
    end
  end

  def set_access
    @access = {}
    if request.env[:authorized_app]
      @access[:api] = {}
      @access[:api][:app] = request.env[:authorized_app]
    else
      # Developer must provide credentials.  Not using oauth.
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

  def request_base_uri
    request.protocol + request.host_with_port
  end

  def set_app
    if api_request?
      @app = authorized_app
    else
      @app = params[:app_id] && current_developer.apps.find(params[:app_id].to_s)  # to_s because we use slug on app
    end

    if !@app
      respond_to do |format|
        format.html { render :status => :forbidden, :text => "Forbidden" }
        format.json { render :status => :forbidden, :json => { message: "Please check your app_key and secret_key." } }
      end
    end
  end
end
