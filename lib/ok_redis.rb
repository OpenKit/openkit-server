=begin

Example usage:

  r = OKRedis.connection
  r.hmset("key1", "field1", "a string", "field2", {'my' => 'hash'}.to_json)
  r.hgetall("key1").class                 #=> Hash
  r.hgetall("key1")                       #=> {"field1"=>"a string", "field2"=>"{\"my\":\"hash\"}"}
  JSON.parse(r.hget('key1', 'field2'))    #=> {"my"=>"hash"}

=end
module OKRedis
  extend self
  def connection
    @connection ||= Redis.new(:host => "localhost", :port => 6379)
  end
end
