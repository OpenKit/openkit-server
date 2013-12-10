class PasswordResetsController < ApplicationController
  skip_before_filter :require_login
  before_filter :load_developer_using_perishable_token, :only => [ :edit, :update ]

  def new
  end

  def create
    @developer = Developer.find_by(emil: params[:email].to_s)
    if @developer
      @developer.deliver_password_reset_instructions!
      flash[:notice] = "Instructions have been sent.  Please check your spam folder if you do not see an email from us within a few minutes."
      redirect_to login_path
    else
      flash.now[:error] = "No developer was found with email address #{params[:email]}"
      render :action => :new
    end
  end

  def edit
  end

  def update
    @developer.password = params[:password].to_s
    @developer.password_confirmation = params[:password_confirmation].to_s

    # Use @developer.save_without_session_maintenance instead if you
    # don't want the developer to be signed in automatically.
    if @developer.save
      flash[:notice] = "Your password was successfully updated"
      redirect_to root_url
    else
      render :action => :edit
    end
  end


  private

  def load_developer_using_perishable_token
    @developer = Developer.find_using_perishable_token(params[:id].to_s)
    unless @developer
      flash[:error] = "We're sorry, but we could not locate your account"
      redirect_to root_url
    end
  end
end