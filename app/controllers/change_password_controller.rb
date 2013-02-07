class ChangePasswordController < ApplicationController
  before_filter :require_dashboard_access

  # GET /change_password/new
  def new
    @change_password = ChangePassword.new
  end

  # POST /change_password
  def create
    @change_password = ChangePassword.new(params[:change_password])
    if @change_password.update_for_developer(current_developer)
      redirect_to developer_path(current_developer), notice: 'Change password was successfully created.'
    else
      render action: "new"
    end
  end
end
