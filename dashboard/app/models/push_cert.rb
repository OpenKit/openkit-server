# I think the way to do this is to keep everything out of memory.  Just deal
# with the files on disk and move from tempfile (via upload) into position to use in
# the push loop.  If we read into mem we are going to being doing a lot of memory movement
# back and forth (between uploading, writing, reading into this obj, reading file for
# push loop)
class PushCert
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  class << self
    attr_accessor :local_path
    def set_local_path(path)
      self.local_path = path
    end

    def find_by_app_key(app_key)
      if File.exists?(pem_path_for_app_key(app_key))
        new(app_key)
      else
        nil
      end
    end

    def pem_path_for_app_key(app_key)
      if local_path.nil?
        raise "Doing it wrong."
      end
      File.join(local_path, "#{app_key}.pem")
    end
  end

  # Which ActiveModel module gives me this?
 # attr_accessible :p12, :p12_pw
  attr_accessor   :p12, :p12_pw
  attr_accessor :app_key

  def initialize(app_key)
    @app_key = app_key
  end

  def bundle_identifier
    begin
      File.read(pem_path, :encoding => "ISO-8859-1").scan(/^subject=.*/)[0].split("\/").detect{|x| x=~/^UID*/}.split("=")[1]
    rescue
      nil
    end
  end

  def pem_path
    @pem_path ||= self.class.pem_path_for_app_key(@app_key)
  end

  def persisted?
    false
  end

  def save
    passing = false
    if p12 && p12.tempfile
      passing = system("openssl pkcs12 -in #{p12.tempfile.path} -out #{pem_path} -passin pass:#{p12_pw} -nodes")
      if !passing
        FileUtils.rm(pem_path) rescue nil
        errors.add(:base, "Could not read your certificate.  Please enter the password that you used to create the .p12 file.")
      end
    else
      errors.add(:base, "Please upload a p12 file")
    end
    passing
  end

  def destroy
    removed = FileUtils.rm(pem_path) rescue nil
    removed
  end
end
