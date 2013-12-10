require File.expand_path('../boot', __FILE__)
require File.expand_path('../ok_config.rb', __FILE__)

require "active_record/railtie"
require "action_controller/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module OKService
  class Application < Rails::Application
    config.middleware.use "TwoLeggedOAuth"
    config.exceptions_app = self.routes

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/app/models/shared)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    I18n.enforce_available_locales = false

    config.generators do |g|
      g.test_framework :mini_test, spec: false, fixture: false
    end

    if OKConfig[:s3_attachment_bucket]
      config.paperclip_defaults = {
        :storage => :s3,
        :s3_credentials => {
          :bucket => OKConfig[:s3_attachment_bucket],
          :access_key_id => OKConfig[:aws_key],
          :secret_access_key => OKConfig[:aws_secret]
        }
      }
    end
    
    config.filter_parameters += [:password]
    
    # Would like to remove, and disable session entirely.
    config.secret_key_base = "bd5ba5c96a1fbc76532fcad56811d06ccf93849edb5f2b3800d2e0990169bd93e0d265708e10cc076c9a5e2ab1c0db066067167ae243234f945df9421774e383"
  end
end
