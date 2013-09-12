=begin

Example usage:

  r = OKRedis.connection
  r.hmset("key1", "field1", "a string", "field2", {'my' => 'hash'}.to_json)
  r.hgetall("key1").class                 #=> Hash
  r.hgetall("key1")                       #=> {"field1"=>"a string", "field2"=>"{\"my\":\"hash\"}"}
  JSON.parse(r.hget('key1', 'field2'))    #=> {"my"=>"hash"}

=end
require 'redis'

module OKRedis
  extend self
  def connection
    @connection ||= Redis.new(:driver => :hiredis, :host => OKConfig[:redis_host], :port => OKConfig[:redis_port])
  end

  def hiconnection
     @hiconnection ||= begin
       x = Hiredis::Connection.new
       x.connect OKConfig[:redis_host], OKConfig[:redis_port].to_i
       x
     end
  end
end
