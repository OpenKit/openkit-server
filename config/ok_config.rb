module OKConfig
  extend self

  def config_hash
    @config_hash ||= begin
    {
      :database_name            => nil || 'openkit',
      :database_username        => nil || 'root',
      :database_password        => nil || '',
      :database_host            => nil || '127.0.0.1',
      :database_port            => nil || '3306',
      :mail_domain              => nil || 'www.example.com',
      :mail_user                => nil || 'no-reply@www.example.com',
      :mail_pass                => nil || 'replaceme',
      :mailer_host              => nil || 'www.example.com'
      :aws_key                  => nil || 'public-aws-key',
      :aws_secret               => nil || 'signing-key',
      :s3_attachment_bucket     => nil || 's3bucketname',
    }
    end
  end

  def [](k)
    config_hash[k]
  end
end



