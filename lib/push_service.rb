# API:
#
#   push_service = PushService.new(:dev)
#   push_service.connect
#   push_service.write(token, payload)
#   push_service.flush
#   push_service.disconnect
#   push_service.reconnect
#
# Example:
# p.connect
# p.write("7263097dd87a783c5d90dfa61ad3df3d17b11428143c788e77c1be4c2d162d38", {aps: {alert: "This is cool!", badge: 1, sound: "default"}, other_meta: 10})
#
require 'socket'
require 'openssl'
require 'json'

class Push
  attr_accessor :token, :alert, :badge, :sound, :meta_fields
  def initialize(token, alert, meta_fields = {})
    @token = token
    @alert = alert
    @meta_fields = meta_fields
  end
end

PUSH_ENVIRONMENT = {
  :dev => {
    :host => 'gateway.sandbox.push.apple.com',
    :port => 2195,
    :pem_path => '/Users/Shared/AppleCerts/OKSampleApp/DevPush.pem',
    :pem_pass => 'this is a good password',
  },
  :prod => {
    :host => 'gateway.push.apple.com',
    :port => 2195,
    :pem_path => '',
    :pem_pass => '',
  }
}

class PushService
  @settings = {}
  @ssl
  @sock

  def initialize(env_key)
    if !PUSH_ENVIRONMENT.include?(env_key)
      raise "Wrong. #{env_key} is not a valid environment key!"
    end

    @settings = PUSH_ENVIRONMENT[env_key]
  end

  def connect
    context      = OpenSSL::SSL::SSLContext.new
    context.cert = OpenSSL::X509::Certificate.new(File.read(@settings[:pem_path]))
    context.key  = OpenSSL::PKey::RSA.new(File.read(@settings[:pem_path]), @settings[:pem_pass])

    retries = 0
    begin
      @sock         = TCPSocket.new(@settings[:host], @settings[:port])
      @ssl          = OpenSSL::SSL::SSLSocket.new(@sock, context)
      @ssl.connect
    rescue SystemCallError
      if (retries += 1) < 5
        sleep 1
        retry
      else
        # Too many retries, re-raise this exception
        raise
      end
    end
  end

  def write(token, payload)
    @ssl.write(packed_notification(token, payload))
    @ssl.flush()
  end

  def reconnect
    disconnect
    connect
  end

  def disconnect
    @ssl.close rescue nil  # don't care
    @sock.close rescue nil # same
  end

  private
  def packed_notification(token, payload)
    pt = [token].pack('H*')
    pm = payload.to_json
    [0, 0, 32, pt, 0, pm.size, pm].pack("ccca*cca*")
  end
end
