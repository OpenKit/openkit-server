module Api::V1
class ClientSessionsController < ApplicationController

  def create
    @client_session = ClientSession.new(params[:client_session])
    @client_session.app_id = authorized_app.id
    # Really we could just be logging these out, as none of the fields
    # in the client_sessions db are indexed.  The only special thing we
    # handle is adding push tokens to a users list, if we have that info.
    if @client_session.ok_id && @client_session.push_token
      if user = authorized_app.developer.users.find_by_id(@client_session.ok_id.to_i)
        tokens = user.tokens.where(app_id: authorized_app.id)
        if !tokens.include?(@client_session.push_token)
          user.tokens.create(app_id: authorized_app.id, apns_token: @client_session.push_token)
        end
      end
    end

    if @client_session.save
      head :ok
    else
      render status: :bad_request, json: {message: @client_session.errors.full_messages.join(", ")}
    end
  end
end
end
