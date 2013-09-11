module Api
class UsersController < ApplicationController
  
  def create
    err_message = nil

    @user = authorized_app.find_or_create_subscribed_user(params[:user])
    err_message = "Could not create that user." if @user.nil?
    err_message = "Couldn't subscribe user because:#{@user.errors.full_messages[0]}" if @user.errors.count != 0

    if !err_message
      u = @user.as_json
      ApiMolding.fb_fix_0_9(u)
      render json: u, status: :created
    else
      render status: :bad_request, json: {message: err_message}
    end
  end
end
end
