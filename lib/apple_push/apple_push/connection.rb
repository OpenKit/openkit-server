require 'socket'
require 'openssl'

module ApplePush
  class Connection
    def initialize(host, combined_pem_path)
      @host = host
      @combined_pem_path = combined_pem_path
      connect()
    end

    def send_push(note)
      write(note.packed)
    end

    def write(x)
      ssl_socket.write(x)
      ssl_socket.flush()
    end

    def disconnect
      ssl_socket.close()
    end

    private
    def connect()
      ssl_socket.connect()
    end

    def ssl_socket
      @ssl_socket ||= OpenSSL::SSL::SSLSocket.new(TCPSocket.new(@host, 2195), context)
    end

    def context
      @context ||= begin
        cert_and_key = File.read(@combined_pem_path)
        context      = OpenSSL::SSL::SSLContext.new
        context.cert = OpenSSL::X509::Certificate.new(cert_and_key)
        context.key  = OpenSSL::PKey::RSA.new(cert_and_key)
        context
      end
      @context
    end
  end
end
