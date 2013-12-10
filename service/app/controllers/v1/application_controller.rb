module V1
class ApplicationController < ActionController::Metal

  include ActionController::Head
  include ActionController::Rendering
  include ActionController::Renderers::All
  include ActionController::MimeResponds
  include AbstractController::Callbacks
  include ActionController::ParamsWrapper

  # For reference:
  # MODULES = [
  #   AbstractController::Layouts,
  #   AbstractController::Translation,
  #   AbstractController::AssetPaths,
  #
  #   ActionController::Helpers,
  #   ActionController::HideActions,
  #   ActionController::UrlFor,
  #   ActionController::Redirecting,
  #   ActionController::Rendering,
  #   ActionController::Renderers::All,
  #   ActionController::ConditionalGet,
  #   ActionController::RackDelegation,
  #   ActionController::Caching,
  #   ActionController::MimeResponds,
  #   ActionController::ImplicitRender,
  #   ActionController::StrongParameters,
  #
  #   ActionController::Cookies,
  #   ActionController::Flash,
  #   ActionController::RequestForgeryProtection,
  #   ActionController::ForceSSL,
  #   ActionController::Streaming,
  #   ActionController::DataStreaming,
  #   ActionController::RecordIdentifier,
  #   ActionController::HttpAuthentication::Basic::ControllerMethods,
  #   ActionController::HttpAuthentication::Digest::ControllerMethods,
  #   ActionController::HttpAuthentication::Token::ControllerMethods,
  #
  #   # Before callbacks should also be executed the earliest as possible, so
  #   # also include them at the bottom.
  #   AbstractController::Callbacks,
  #
  #   # Append rescue at the bottom to wrap as much as possible.
  #   ActionController::Rescue,
  #
  #   # Add instrumentations hooks at the bottom, to ensure they instrument
  #   # all the methods properly.
  #   ActionController::Instrumentation,
  #
  #   # Params wrapper should come before instrumentation so they are
  #   # properly showed in logs
  #   ActionController::ParamsWrapper
  # ]
  #
  # MODULES.each do |mod|
  #   include mod
  # end

  wrap_parameters format: :json
  respond_to :json
  before_filter :require_authorized_app

  private
  def authorized_app
    return @authorized_app if defined?(@authorized_app)
    @authorized_app = request.env[:authorized_app]
  end

  def require_authorized_app
    unless authorized_app
      render :status => 401, :json => { message: "Please check your app_key and secret_key." }
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

  def in_sandbox?
    !!request.subdomain.match(/^(?:beta-)?sandbox$/)
  end

end
end
