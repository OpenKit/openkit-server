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
      :mail_domain              => nil || 'www.example.com',
      :mail_user                => nil || 'no-reply@www.example.com',
      :mail_pass                => nil || 'replaceme',
      :mailer_host              => nil || 'www.example.com',
      :aws_key                  => nil || 'public-aws-key',
      :aws_secret               => nil || 'signing-key',
      :s3_attachment_bucket     => nil || 's3bucketname',
      :rails_secret_token       => nil || 'd793c6549176d97e349148dbdf8a5288d129313592117c8a4b4d80a328b2e1f4618d2ead0bf0fe84cb7df22a8d64ecbf8afc4b7cc815cf14f5473019b6184878',
      :rails_session_store_key  => nil || '_openkit_session'
    }
    end
  end

  def [](k)
    config_hash[k]
  end
end



