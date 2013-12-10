ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => OKConfig[:mail_domain],
  :user_name            => OKConfig[:mail_user],
  :password             => OKConfig[:mail_pass],
  :authentication       => "plain",
  :enable_starttls_auto => true
}

mailer_host = OKConfig[:mailer_host]
ActionMailer::Base.default_url_options[:host] = mailer_host
# Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
