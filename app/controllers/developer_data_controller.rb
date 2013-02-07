class DeveloperDataController < ApplicationController
  before_filter :require_api_access,              :only => [:create]
  before_filter :require_dashboard_access,        :only => [:index, :destroy]
  before_filter :require_dashboard_or_api_access, :only => [:show]

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
    dev_data = get_interface(params[:user_id], err_out)
    if err_out.blank?
      x = dev_data.get(key)
    end

    if err_out.blank?
      json = "{#{key.to_json}: #{x}}"
      render json: json
    else
      render status: :bad_request, json: {message: err_out}
    end

    #respond_to do |format|
    #  format.html # show.html.erb
    #  format.json { render json: @developer_data }
    #end
  end

  # GET /developer_data/new
  # GET /developer_data/new.json
  def new
    @developer_data = OKData.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @developer_data }
    end
  end

  # GET /developer_data/1/edit
  def edit
    @developer_data = OKData.find(params[:id])
  end

  # POST /developer_data
  # POST /developer_data.json
  def create
    err_out = ""
    dev_data = get_interface(params[:user_id], err_out)
    if err_out.blank?
      dev_data.set(params[:field_key], params[:field_value])
    end

    if err_out.blank?
      render status: :created, json: {ok: "yay"}
    else
      render status: :bad_request, json: {message: err_out}
    end

#    respond_to do |format|
#      if @developer_data.save
#        format.html { redirect_to @developer_data, notice: 'Ok data was successfully created.' }
#        format.json { render json: @developer_data, status: :created, location: @developer_data }
#      else
#        format.html { render action: "new" }
#        format.json { render json: @developer_data.errors, status: :unprocessable_entity }
#      end
#    end
  end

  # PUT /developer_data/1
  # PUT /developer_data/1.json
  def update
    @developer_data = OKData.find(params[:id])

    respond_to do |format|
      if @developer_data.update_attributes(params[:developer_data])
        format.html { redirect_to @developer_data, notice: 'Ok data was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @developer_data.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /developer_data/1
  # DELETE /developer_data/1.json
  def destroy
    @developer_data = OKData.find(params[:id])
    @developer_data.destroy

    respond_to do |format|
      format.html { redirect_to developer_data_url }
      format.json { head :no_content }
    end
  end

  private
  def get_interface(user_id, err_out)
    dev_data = nil
    if api_developer = current_app && current_app.developer
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
