require 'colorize'
require_relative 'system_config'

class DependencyCheck

  def list
    [:aws_cli, :openkit_config]
  end

  def run
    list.each do |x|
      check_system_for(x)
    end
  end

  def check_system_for(x)
    print "checking system for #{x}..."
    if has(x)
      puts "found".green
    else
      puts "not found".red
      error_on(x)
      exit 1
    end
  end

  # system checks and error messages go here
  def has_aws_cli
    system("which aws 2>&1 1>/dev/null") &&
    `aws --version 2>&1` =~ /aws-cli/
  end

  def error_on_aws_cli
    STDERR.print <<-EOS

    Amazon's command line tool is required for the provisioning scripts.
    Install it with:
      $ brew install python
      $ pip install awscli
      $ aws configure
    EOS
  end

  def has_openkit_config
    system "test -e #{SystemConfig.path}"
  end

  def error_on_openkit_config
    STDERR.print <<-EOS

    An OpenKit system configuration file is required at the top level
    of the openkit-server project.  An example file is provided at
    openkit-server/#{SystemConfig.example_name}.  You should move it into place
    with:

      $ mv #{SystemConfig.example_name} #{SystemConfig.name}

    Then edit the file to contain real values.
    EOS
  end


  private
  def has(name)
    method("has_#{name}").call
  end

  def error_on(name)
    method("error_on_#{name}").call
  end
end

