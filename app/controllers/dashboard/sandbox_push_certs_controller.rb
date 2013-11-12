module Dashboard
class SandboxPushCertsController < ApplicationController
  before_filter :set_app

  def new
    @sandbox_push_cert = SandboxPushCert.new(@app.app_key)
  end

  def create
    @sandbox_push_cert        =  SandboxPushCert.new(@app.app_key)
    @sandbox_push_cert.p12    =  params[:sandbox_push_cert]['p12']
    @sandbox_push_cert.p12_pw =  params[:sandbox_push_cert]['p12_pw']

    if @sandbox_push_cert.save
      redirect_to @app, notice: 'Sandbox push cert was successfully created.'
    else
      render action: 'new'
    end
  end

  def destroy
    if @app.sandbox_push_cert.destroy
      redirect_to @app, notice: 'Deleted the sandbox push cert.'
    else
      redirect_to @app, notice: 'Could not delete that push cert, contact lou@openkit.io for help.'
    end
  end

  def test_project
    if @app.sandbox_push_cert.nil?
      render :text => "Please upload a sandbox push certificate first."
    elsif @app.sandbox_push_cert.bundle_identifier.nil?
      render :text => "Could not parse the bundle identifier from your push certificate.  Please contact lou@openkit.io"
    else
      p = PushTestProject.new(@app.sandbox_push_cert.bundle_identifier)
      if !p.construct
        render :text => "Could not create zip of project.  Please contact lou@openkit.io"
      else
        send_file p.path_to_zip
      end
    end
  end
end
end
