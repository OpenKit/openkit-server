module V1
class ClientSessionsController < ApplicationController

  def create
    @client_session = client_session_class.new(params[:client_session])
    @client_session.app_id = authorized_app.id
    # Really we could just be logging these out, as none of the fields
    # in the client_sessions db are indexed.  The only special thing we
    # handle is adding push tokens to a users list, if we have that info.
    if @client_session.ok_id && @client_session.push_token
      if user = authorized_app.developer.users.find_by_id(@client_session.ok_id.to_i)
        token_class.find_or_create_by_user_id_and_app_id_and_apns_token(user.id, authorized_app.id, @client_session.push_token)
      end
    end

    if @client_session.save
      head :ok
    else
      render status: :bad_request, json: {message: @client_session.errors.full_messages.join(", ")}
    end
  end

  private
  def client_session_class
    @client_session_class ||= in_sandbox? ? SandboxClientSession : ClientSession
  end

  def token_class
    @token_class ||= in_sandbox? ? SandboxToken : Token
  end

end
end
