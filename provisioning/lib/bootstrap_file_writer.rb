require 'erb'
require_relative 'system_config'

class BootstrapFileWriter

  def initialize
    @email      = SystemConfig['email']
    @public_key = SystemConfig['public_key']
    raise "Email missing from system config"      unless @email
    raise "Public key missing from system config" unless @public_key
  end

  def run
    output_file = File.join provisioning_root, "tmp", "bootstrap_min.userdata"
    begin
      File.open output_file, "w" do |f|
        f.print rendered_template
      end
    rescue => e
      STDERR.puts "Could not write boostrap file, error:\n\n"
      raise e
    end
  end

  def rendered_template
    template = File.join provisioning_root, "templates", "bootstrap_min.userdata.erb"
    erb = ERB.new File.read(template)
    erb.result(binding)
  end

  def provisioning_root
    File.expand_path "../..", __FILE__
  end
end
