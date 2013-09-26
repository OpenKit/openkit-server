#
# $ PUSH_ENV=sandbox bundle exec ruby lib/push_loop.rb
#
require 'thread'
begin
  require 'fastthread'
rescue LoadError
end
# require 'debugger'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'ok_config.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), 'ok_redis.rb'))
require File.expand_path(File.join(File.dirname(__FILE__), 'push_service.rb'))

PNContainer = Struct.new(:push_service, :push_service_lock)

class PushLoop
  IDLE_TIMEOUT = 60  # Closing connections to Apple after 1 minute of being idle

  def log(x)
    $stdout.puts x
    $stdout.flush
  end

  def initialize(in_sandbox = false)
    @in_sandbox = in_sandbox
  end

  def run
    log "starting in #{@in_sandbox ? 'sandbox' : 'production'}..."
    # Keyed by app_key
    pn_containers = {}
    last_write_mutexes = {}
    active_ids_mutex = Mutex.new

    push_thread = Thread.new do
      sleep 1
      log "push_thread: Beginning..."
      current_thread = Thread.current
      current_thread[:active_app_keys] = []

      begin
        while(1)
          k = @in_sandbox ? 'sandbox_pn_queue' : 'pn_queue'
          entry = OKRedis.connection.brpop(k)
          log "push_thread: Popped a push entry: #{entry}"
          app_key, token, payload = JSON.parse(entry[1])

          # Make sure this is a sane push
          if app_key.is_a?(String) && !app_key.empty? && token.is_a?(String) && token.length == 64 && payload.is_a?(Hash) && payload.has_key?('aps')
            log "push_thread: Push is sane for app_key #{app_key}"

            pn_containers[app_key] ||= PNContainer.new(PushService.new(app_key, {in_sandbox: @in_sandbox}), Mutex.new)
            last_write_mutexes[app_key] ||= Mutex.new

            active_ids_mutex.synchronize {
              if !current_thread[:active_app_keys].include?(app_key)
                  current_thread[:active_app_keys] << app_key
              end
            }

            log "push_thread: Sending - app_key: #{app_key}, Token: #{token}, Payload: #{payload.inspect}"
            c = pn_containers[app_key]
            c.push_service_lock.synchronize {
              if !c.push_service.is_connected?
                log "push_thread: Push service for app_key #{app_key} is not yet connected. Connecting now..."
                if c.push_service.reconnect
                  log "push_service: connected!"
                end
              end
              c.push_service.reconnect unless c.push_service.is_connected?
              # Letting the loop crash if Errno::ETIMEDOUT is hit.
              c.push_service.write(token, payload)
            }

            last_write_mutexes[app_key].synchronize {
              current_thread["#{app_key}_last"] = Time.now
            }
          end
        end
      rescue => e
        log "push_thread: Failing #{e}"
        e.backtrace.each {|line| log line}
        exit 1
      end
    end


    disconnect_thread = Thread.new do
      log "disconnect_thread: Beginning..."
      begin
        while(1)
          log "disconnect_thread: Sleeping for #{IDLE_TIMEOUT}"
          sleep IDLE_TIMEOUT

          # Get the app_keys that we are watching
          app_keys = nil
          log "disconnect_thread: About to get active_ids_mutex..."
          active_ids_mutex.synchronize {
            app_keys = push_thread[:active_app_keys]
          }
          log "disconnect_thread: Monitoring #{app_keys.inspect}"

          close_ids = []
          app_keys.each do |app_key|
            log "disconnect_thread: Getting last write mutex for #{app_key}..."
            last_write_mutexes[app_key].synchronize {
              if Time.now - push_thread["#{app_key}_last"] > IDLE_TIMEOUT
                log "disconnect_thread: There was NO write within the last #{IDLE_TIMEOUT} seconds for app_key #{app_key}."
                close_ids << app_key
              else
                log "disconnect_thread: app_key #{app_key} has been active in last #{IDLE_TIMEOUT} seconds."
              end
            }
          end

          close_ids.each do |app_key|
            c = pn_containers[app_key]
            log "disconnect_thread: Getting push service mutex for #{app_key}"
            c.push_service_lock.synchronize {
              if c.push_service.is_connected?
                log "** No write in the last #{IDLE_TIMEOUT}! Disconnecting from Apple."
                c.push_service.disconnect
              end
            }
          end

          log "disconnect_thread: Getting the active_ids_mutex to remove #{close_ids.inspect}"
          active_ids_mutex.synchronize {
            push_thread[:active_app_keys] -= close_ids
          }

        end
      rescue => e
        log "disconnect_thread: Failing #{e}"
        e.backtrace.each {|line| log line}
        exit 1
      end
    end

    push_thread.join
  end
end

PushLoop.new(ENV['PUSH_ENV'] == 'sandbox').run
