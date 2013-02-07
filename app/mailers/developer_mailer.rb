class DeveloperMailer < ActionMailer::Base
  default from: "OpenKit <no-reply@openkit.io>"
  default content_type: "text/html"

  def password_reset_instructions(developer)
    @edit_password_reset_url = edit_password_reset_url(developer.perishable_token)
    mail(:to => developer.email, :subject => "OpenKit Reset Password Instructions")
  end
end
