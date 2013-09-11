module Dashboard
class ChangePasswordController < ApplicationController

  # GET /change_password/new
  def new
    @change_password = ChangePassword.new
  end

  # POST /change_password
  def create
    params.delete(:developer)
    @change_password = ChangePassword.new(params[:change_password].merge(developer: current_developer))
    if @change_password.save
      redirect_to developer_path(current_developer), notice: 'Change password was successfully created.'
    else
      render action: "new"
    end
  end
end
end