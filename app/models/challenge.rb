=begin
  # Send myself a challenge from Todd:
  >
  > challenge = Challenge.new(sender_id: 2, receiver_ids:[3], leaderboard_id: 1, developer: Developer.first, app_id: 1)
  > challenge.save
=end
class Challenge

  attr_accessor :sender_id, :receiver_ids, :leaderboard_id, :app_id, :challenge_uuid
  attr_accessor :developer

  def errors
    @errors ||= []
  end

  def notices
    @notices ||= []
  end


  def initialize(h={})
    h && h.each do |name, value|
      send("#{name}=", value) if respond_to? name.to_sym
    end
  end

  def save
    errors.push "sender_id is required"               unless sender_id
    errors.push "receiver_ids is required"            unless !receiver_ids.blank?
    errors.push "leaderboard_id is required"          unless leaderboard_id
    errors.push "app_id is required"                  unless app_id
    errors.push "developer is required"               unless developer
    errors.push "sender_id is not an accessible user" unless developer.has_user?(sender_id)

    @safe_receivers = []
    receiver_ids.each do |r_id|
      if developer.has_user?(r_id)
        @safe_receivers << r_id
      end
    end

    if errors.empty?
      if !enqueue
        errors.push "Could not enqueue challenge"
      end
    end
    errors.empty?
  end

  private
  def enqueue
    tokens = []
    sender = User.find_by_id(sender_id)
    if sender
      @safe_receivers.each do |r_id|
        u = User.find_by_id(r_id)
        if u
          t = u.tokens.where(app_id: app_id).uniq_by(&:apns_token)
          tokens |= t if !t.empty?
        end
      end

      if !tokens.empty?
        OKRedis.connection.sadd(OKConfig[:pn_dev_ids_key], developer.id)
        tokens.each do |token|
          package = {aps: {alert: "Your friend #{sender.nick} beat you!", badge: 1, sound: "default"}, challenge_uuid: challenge_uuid}
          entry = [developer.id, token.apns_token, package]
          OKRedis.connection.lpush("pn_queue", entry.to_json)
        end
      end
    end

    true
  end
end
