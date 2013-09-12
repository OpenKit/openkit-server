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

  def run
    log "starting..."
    # Keyed by developer id
    pn_containers = {}
    last_write_mutexes = {}
    active_ids_mutex = Mutex.new

    push_thread = Thread.new do
      sleep 1
      log "push_thread: Beginning..."
      current_thread = Thread.current
      current_thread[:active_dev_ids] = []

      begin
        while(1)
          entry = OKRedis.connection.brpop(OKConfig[:pn_queue_key])
          log "push_thread: Popped a push entry: #{entry}"
          dev_id, token, payload = JSON.parse(entry[1])

          # Make sure this is a sane push
          if dev_id.is_a?(Fixnum) && dev_id != 0 && token.is_a?(String) && token.length == 64 && payload.is_a?(Hash) && payload.has_key?('aps')
            log "push_thread: Push is sane for dev #{dev_id}"

            pn_containers[dev_id] ||= PNContainer.new(PushService.new(dev_id), Mutex.new)
            last_write_mutexes[dev_id] ||= Mutex.new

            active_ids_mutex.synchronize {
              if !current_thread[:active_dev_ids].include?(dev_id)
                  current_thread[:active_dev_ids] << dev_id
              end
            }

            log "push_thread: Sending - Dev id: #{dev_id}, Token: #{token}, Payload: #{payload.inspect}"
            c = pn_containers[dev_id]
            c.push_service_lock.synchronize {
              if !c.push_service.is_connected?
                log "push_thread: Push service for dev #{dev_id} is not yet connected. Connecting now..."
                if c.push_service.reconnect
                  log "push_service: connected!"
                end
              end
              c.push_service.reconnect unless c.push_service.is_connected?
              # Letting the loop crash if Errno::ETIMEDOUT is hit.
              c.push_service.write(token, payload)
            }

            last_write_mutexes[dev_id].synchronize {
              current_thread["dev_#{dev_id}_last"] = Time.now
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

          # Get the developer ids that we are watching
          dev_ids = nil
          log "disconnect_thread: About to get active_ids_mutex..."
          active_ids_mutex.synchronize {
            dev_ids = push_thread[:active_dev_ids]
          }
          log "disconnect_thread: Monitoring #{dev_ids.inspect}"

          close_ids = []
          dev_ids.each do |dev_id|
            log "disconnect_thread: Getting last write mutex for #{dev_id}..."
            last_write_mutexes[dev_id].synchronize {
              if Time.now - push_thread["dev_#{dev_id}_last"] > IDLE_TIMEOUT
                log "disconnect_thread: There was NO write within the last #{IDLE_TIMEOUT} seconds for developer #{dev_id}."
                close_ids << dev_id
              else
                log "disconnect_thread: Developer #{dev_id} has been active in last #{IDLE_TIMEOUT} seconds."
              end
            }
          end

          close_ids.each do |dev_id|
            c = pn_containers[dev_id]
            log "disconnect_thread: Getting push service mutex for #{dev_id}"
            c.push_service_lock.synchronize {
              if c.push_service.is_connected?
                log "** No write in the last #{IDLE_TIMEOUT}! Disconnecting from Apple."
                c.push_service.disconnect
              end
            }
          end

          log "disconnect_thread: Getting the active_ids_mutex to remove #{close_ids.inspect}"
          active_ids_mutex.synchronize {
            push_thread[:active_dev_ids] -= close_ids
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

PushLoop.new.run
