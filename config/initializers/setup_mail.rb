ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "__:maildomain:__",
  :user_name            => "__:mailuser:__",
  :password             => "__:mailpass:__",
  :authentication       => "plain",
  :enable_starttls_auto => true
}

mailer_host = case Rails.env
when "development" then "localhost:3000"
when "production" then "stage.openkit.io"
end
ActionMailer::Base.default_url_options[:host] = mailer_host
# Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
