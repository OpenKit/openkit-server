class UsersController < ApplicationController
  before_filter :require_dashboard_access,  :except => [:new, :create, :update]
  before_filter :require_api_access,        :only   => [:new, :create, :update]

  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id].to_i)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id].to_i)
  end

  # POST /users
  # POST /users.json
  def create
    err_message = nil

    @user = authorized_app.find_or_create_subscribed_user(params[:user])
    err_message = "Could not create that user." if @user.nil?
    err_message = "Couldn't subscribe user because:#{@user.errors.full_messages[0]}" if @user.errors.count != 0

    if !err_message
      render json: @user, status: :created, location: @user
    else
      render status: :bad_request, json: {message: err_message}
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id].to_i)

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        #format.json { head :no_content }
        format.json { render json: @user, status: :ok, location: @user }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id].to_i)
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
end
