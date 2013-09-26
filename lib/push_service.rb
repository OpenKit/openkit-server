# API:
#
#   p = PushService.new(app_key, {in_sandbox: true})
#   p.connect
#   p.write_message(token, message)
#   p.write(token, payload)
#   p.disconnect
#   p.reconnect
#   p.is_connected?
#
# OR in IRB:
#
#   > PushService.chat_with_lou
#   Each time you hit enter, Lou gets a push note. Use ctrl+d to exit.
#
# Example:
# p.connect
# p.write("7263097dd87a783c5d90dfa61ad3df3d17b11428143c788e77c1be4c2d162d38", {aps: {alert: "This is cool!", badge: 1, sound: "default"}, other_meta: 10})
#
# $ gpg --force-mdc -c 1_p.txt
# $ gpg --yes --batch -d --passphrase='password' 1_p.txt.gpg
#
#
require 'socket'
require 'openssl'
require 'json'
require 'gpgme'
# require 'debugger'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'ok_config.rb'))

class PushService

  def is_connected?
    @connected
  end

  def initialize(app_key, opts = {})
    @app_key = app_key
    @in_sandbox = opts[:in_sandbox]
    @connected = false
  end

  def connect
    if !pem_and_pass_exist?
      $stderr.puts "Pem and pass files do not exist for app_key #{@app_key}"
      return false
    end

    pass = %x(gpg --yes --batch -d --passphrase='#{OKConfig[:pem_disk_pass]}' #{pass_path}).chomp
    #crypto = GPGME::Crypto.new(:password => OKConfig[:pem_disk_pass])
    #pass = crypto.decrypt(File.open(pass_path)).read.chomp

    context      = OpenSSL::SSL::SSLContext.new
    context.cert = OpenSSL::X509::Certificate.new(File.read(pem_path))
    context.key  = OpenSSL::PKey::RSA.new(File.read(pem_path), pass)

    retries = 0
    begin
      @sock         = TCPSocket.new(OKConfig.apns_host(@in_sandbox), 2195)   # 2195 by both sandbox and production?
      @ssl          = OpenSSL::SSL::SSLSocket.new(@sock, context)
      @ssl.connect
      @connected = true
      return true
    rescue SystemCallError => e
      if (retries += 1) < 5
        $stderr.puts "Connection failed for app_key #{@app_key}.  Retrying..."
        sleep 1
        retry
      else
        $stderr.puts "Too many retries for app_key #{@app_key}.  Connection failed with error: #{e.message}"
        return false
      end
    end
  end

  def write(token, payload)
    begin
      @ssl.write(packed_notification(token, payload))
      @ssl.flush
      return true
    rescue => e
      $stderr.puts "Connection for app_key #{@app_key} failed on write.  Message: #{e.message}"
      @connected = false
      return false
    end
  end

  def write_message(token, message)
    write(token, {aps: {alert: message, badge: 0, sound: "default"}})
  end

  def reconnect
    disconnect if @connected
    connect
  end

  def disconnect
    @ssl.close rescue nil  # don't care
    @sock.close rescue nil # same
    @connected = false
    true
  end

  class << self
    def chat_with_lou
      p = PushService.new("doesnotwork", {in_sandbox: true})
      p.connect
      puts "ctrl+d to exit"
      while ((line = gets) && p.is_connected?)
        line.chomp! if line
        p.write_message("7263097dd87a783c5d90dfa61ad3df3d17b11428143c788e77c1be4c2d162d38", line)
      end
      p.disconnect
    end
  end

  private
  def packed_notification(token, payload)
    pt = [token].pack('H*')
    pm = payload.to_json
    [0, 0, 32, pt, 0, pm.size, pm].pack("ccca*cca*")
  end

  def pem_and_pass_exist?
    File.exist?(pem_path) && File.exist?(pass_path)
  end

  def pem_path
    @pem_path ||= OKConfig.pem_path(@app_key, @in_sandbox)
  end

  def pass_path
    @pass_path ||= OKConfig.pem_pass_path(@app_key, @in_sandbox)
  end
end
