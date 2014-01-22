require 'yaml'

module SystemConfig
  extend self

  def yaml
    @yaml ||= YAML.load_file(path)
  end

  def [](k)
    yaml[k]
  end

  def example_name
    "#{name}.example"
  end

  def name
    "system.yml"
  end

  def path
    "#{project_root}/#{name}"
  end

  def current_dir
    File.expand_path "..", __FILE__
  end

  def project_root
    File.join current_dir, "../.."
  end
end
