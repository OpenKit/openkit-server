class ProductionPushCertsController < ApplicationController
  before_filter :set_app

  def new
    @production_push_cert = ProductionPushCert.new(@app.app_key)
  end

  def create
    @production_push_cert        =  ProductionPushCert.new(@app.app_key)
    @production_push_cert.p12    =  params[:production_push_cert]['p12']
    @production_push_cert.p12_pw =  params[:production_push_cert]['p12_pw']

    if @production_push_cert.save
      redirect_to app_push_notes_path(@app), notice: 'Production push cert was successfully created.'
    else
      render action: 'new'
    end
  end

  def destroy
    if @app.production_push_cert.destroy
      redirect_to app_push_notes_path(@app), notice: 'Deleted the production push cert.'
    else
      redirect_to app_push_notes_path(@app), notice: 'Could not delete that push cert, contact lou@openkit.io for help.'
    end
  end
end
