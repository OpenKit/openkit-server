module Api::V1
class ApplicationController < ActionController::Base
  layout false
  respond_to :json
  before_filter :require_authorized_app

  private
  def authorized_app
    return @authorized_app if defined?(@authorized_app)
    @authorized_app = request.env[:authorized_app]
  end

  def require_authorized_app
    unless authorized_app
      render :status => :forbidden, :json => { message: "Please check your app_key and secret_key." }
    end
  end

  def content_type_json?
    request.content_type == "application/json"
  end

  def accepts_json?
    request.accepts.include?("application/json") || request.accepts.include?("*/*")
  end

  def request_base_uri
    request.protocol + request.host_with_port
  end
end
end
