#
# $ bundle exec ruby lib/push_loop.rb
#
require 'thread'
begin
  require 'fastthread'
rescue LoadError
end


path = File.expand_path(File.dirname(__FILE__))
require File.join(path, '..', 'config', 'ok_config.rb')
require File.join(path, 'ok_redis.rb')
require File.join(path, 'apple_push', 'apple_push.rb')


class PushLoop

  def log(x)
    $stdout.puts x
    $stdout.flush
  end

  def run
    log "starting..."

    k = 'pn_queue_2'
    while 1
      entry = OKRedis.brpop(k)
      log "push_thread: Popped a push entry: #{entry}"
      pem_path, token, payload, in_sandbox = JSON.parse(entry[1])

      # Make sure this is a sane push
      if pem_path.is_a?(String) && !pem_path.empty? && token.is_a?(String) && token.length == 64 && payload.is_a?(Hash) && payload.has_key?('aps')
        log "push_thread: Sending - pem_path: #{pem_path}, Token: #{token}, Payload: #{payload.inspect}"
        if in_sandbox
          puts '------sending to sandbox'
          ApplePush::Sandbox.deliver(token, payload, pem_path)
        else
          puts '------sending to production'
          # ApplePush::Production.deliver(token, payload, pem_path)
        end
      end
    end
  end
end

PushLoop.new.run
