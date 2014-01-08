=begin

Example usage:

  OKRedis.set "foo", "bar"
  OKRedis.get "foo"                   # => "bar"

  OKRedis.hmset   "my_key", "field1", "foo", "field2", "bar"
  OKRedis.hget    "my_key", "field1"  # => "foo"
  OKRedis.hgetall "my_key"            # => {"field1"=>"foo", "field2"=>"bar"}

=end
require 'redis'

module OKRedis
  extend self

  def connection
    @connection ||= ::Redis.new(:driver => :hiredis, :host => OKConfig[:redis_host], :port => OKConfig[:redis_port])
  end

  def method_missing(sym, *args, &block)
    if connection.respond_to? sym
      return connection.send(sym, *args, &block)
    end
    super(sym, *args, &block)
  end

  def respond_to_missing?(method, *)
    connection.respond_to?(method) || super
  end
end
