# If we close or timeout a connection to Apple, we don't keep the connection
# object around.  Connection list is keyed by combined_pem_path.

# require 'debugger'

module ApplePush

  module Pusher  # Man
    extend self

    def m1
      @m1 ||= Mutex.new
    end

    def m2
      @m2 ||= Mutex.new
    end

    def active
      @active ||= {}
    end

    # The killer self-destructs when it has no more connections to watch.
    def create_killer_thread
      Thread.new do |killer|
        keep_alive = true
        idle_timeout = 20

        while keep_alive
          sleep idle_timeout
          now = Time.now.to_i
          remove = []

          m1.synchronize {
            active.each do |pem, t|
              remove.push(pem) if (now - t > idle_timeout)
            end

            remove.each do |pem|
              puts "Killing connection for pem: #{pem}"
              active.delete(pem)
              connections[pem].disconnect rescue nil
              connections.delete(pem)
            end
            keep_alive = !connections.empty?
          }
        end

        m2.synchronize {
          puts "Letting the GC kill the killer."
          @killer = nil
        }
      end
    end

    def killer
      m2.synchronize {
        if @killer.nil?
          puts "Creating killer thread"
          @killer = create_killer_thread
        end
      }
    end

    # Returns false if we couldn't get it out the door.
    def deliver(token, payload, pem)
      note = Note.new(token, payload)
      max_retries = 3
      retries = 0
      begin
        m1.lock
        if (connections[pem]).nil?
          puts "No connection yet for pem #{pem}, creating it."
          connections[pem] = ApplePush::Connection.new(self.host, pem)
        end
        connections[pem].write(note.packed)
        active[pem] = Time.now.to_i
        m1.unlock
        killer()
        return true
      rescue => e
        connections[pem].disconnect rescue nil
        connections.delete(pem)
        active.delete(pem)
        m1.unlock
        if (retries += 1) < max_retries
          $stderr.puts "Push failed with host: #{host}, pem: #{pem}, error: #{e.message}.  Retrying..."
          sleep 1
          retry
        else
          $stderr.puts "Too many retries for host: #{host}, pem: #{pem}.  Failed with error: #{e.message}"
          return false
        end
      end
    end

    def host
      raise "Doing it wrong."
    end

    def connections
      raise "Doing it wrong."
    end
  end

  module Sandbox
    extend Pusher
    extend self
    def host
      @host ||= 'gateway.sandbox.push.apple.com'
    end

    def connections
      @sandbox_connections ||= {}
    end
  end

  module Production
    extend Pusher
    extend self
    def host
      @host ||= 'gateway.push.apple.com'
    end

    def connections
      @production_connections ||= {}
    end
  end
end
