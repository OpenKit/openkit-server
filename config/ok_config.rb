module OKConfig
  extend self

  def config_hash
    @config_hash ||= begin
    {
      :database_name            => nil || 'leaderboard_dev',
      :database_username        => nil || 'root',
      :database_password        => nil || '',
      :database_host            => nil || '127.0.0.1',
      :database_port            => nil || '3306',
      :redis_host               => nil || '127.0.0.1',
      :redis_port               => nil || '6379',
      :mail_domain              => nil || 'www.example.com',
      :mail_user                => nil || 'no-reply@www.example.com',
      :mail_pass                => nil || 'replaceme',
      :mailer_host              => nil || 'www.example.com',
      :aws_key                  => nil || ENV['AWS_ACCESS_KEY_ID']     || 'public-aws-key',
      :aws_secret               => nil || ENV['AWS_SECRET_ACCESS_KEY'] || 'signing-key',
      :s3_attachment_bucket     => nil || ENV['OK_S3_ATTACHMENT_BUCKET'],
      :rails_secret_token       => nil || 'd793c6549176d97e349148dbdf8a5288d129313592117c8a4b4d80a328b2e1f4618d2ead0bf0fe84cb7df22a8d64ecbf8afc4b7cc815cf14f5473019b6184878',
      :rails_session_store_key  => nil || '_openkit_session'
    }
    end
  end

  def [](k)
    config_hash[k]
  end
end



