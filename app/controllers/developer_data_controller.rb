class DeveloperDataController < ApplicationController
  before_filter :require_api_access,              :only => [:create, :show]
  before_filter :require_dashboard_access,        :only => [:index]

  # All data for this developer
  def index
    developer_data = DeveloperData.new(current_developer)
    cloud_user_ids = developer_data.all_user_ids

    # Get users for the first 10
    x = cloud_user_ids[0..9]
    @users = User.find_by_ids(x)
    #@users.collect {|user| user.cloud_data = developer_data.

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @developer_data }
    end
  end

  # GET /developer_data/1
  # GET /developer_data/1.json
  def show
    key = params.delete(:id).to_s
    err_out = ""
    dev_data = get_interface(params[:user_id].to_i, err_out)
    if err_out.blank?
      x = dev_data.get(key)
    end

    if err_out.blank?
      json = "{#{key.to_json}:#{x}}"
      render json: json
    else
      render status: :bad_request, json: {message: err_out}
    end

    #respond_to do |format|
    #  format.html # show.html.erb
    #  format.json { render json: @developer_data }
    #end
  end

  # POST /developer_data
  # POST /developer_data.json
  def create
    err_out = ""
    dev_data = get_interface(params[:user_id].to_i, err_out)
    if err_out.blank?
      dev_data.set(params[:field_key], params[:field_value])
    end

    if err_out.blank?
      render json: {ok: "yay"}
    else
      render status: :bad_request, json: {message: err_out}
    end
  end


  private
  def get_interface(user_id, err_out)
    dev_data = nil
    if api_developer = authorized_app && authorized_app.developer
      dev_data = DeveloperData.new(api_developer)
      if user = api_developer.users.find_by_id(user_id)
        dev_data.user = user
      else
        err_out << "The submitted user does not belong to developer of app_key" unless user
      end
    else
      err_out << "Could not find developer for app_key" unless api_developer
    end
    dev_data
  end

end
