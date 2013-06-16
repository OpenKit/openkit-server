# We will use either 'appendfsync everysec' or 'appendfsync always'.
# For all data, we could provide raw look at the developer's redis instance?
# Does each developer get his/her own redis instance?
#
# Could use this and namespace on developer_id:
# http://github.com/defunkt/redis-namespace
#
# Stuff I need this class to do:
#   1. Given a developer, I need to get all user_ids that are using cloud storage
#   2. Given a developer and a user, I need to:
#      * retrieve all data stored by this user
#      * set data under a specific key for that user
#      * retrieve data under a specific key for that user
#
# Outstanding questions:
#   Should I be storing the type passed by client into the user data?
#
# Use multiple databases:
#   http://rediscookbook.org/multiple_databases.html
# Get stats from each database:
#   https://github.com/antirez/redis-sampler
#
class DeveloperData
  attr_accessor :user

  @@connection
  class << self
    def connection
      @@connection ||= OKRedis.connection
    end
  end
  def connection
    self.class.connection
  end

  # Don't allow ids in init.  This way a param[:developer_id], for example, will
  # not be passed in.  We force security to be handled at a different layer.
  # See: http://redis.io/topics/security
  def initialize(developer)
    @developer = developer
  end

  def all_user_ids
    connection.smembers(all_users_key)
  end

  def set(field_key, field_val)
    raise ArgumentError, "Doing it wrong." unless @user
    connection.sadd(all_users_key, @user.id)
    field_val = field_val.to_json
    connection.hmset(user_data_key(@user.id), field_key, field_val)
  end

  def get(field_key)
    raise ArgumentError, "Doing it wrong." unless @user
    x = connection.hget(user_data_key(@user.id), field_key)
    x
  end

  private
  def all_users_key
    "dev:#{@developer.id}:users"
  end

  def user_data_key(user_id)
    "dev:#{@developer.id}:user:#{user_id}"
  end
end

