class Challenge

  attr_accessor :sender_id, :receiver_ids, :leaderboard_id, :app_id
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

    receiver_ids.each do |r_id|
      errors.push "receiver_id #{r_id} is not an accessible user" unless developer.has_user?(r_id)
    end

    if errors.empty?
      if !enqueue
        errors.push "Could not enqueue challenge"
      end
    end
    errors.empty?
  end

  private
  # TODO: Fix.
  def enqueue
    # OKRedis.connection.set(developer.push_queue_key, {sender_id: sender_id, receiver_ids: receiver_ids, cert_path: @developer.cert_path, leaderboard_id: leaderboard_id})
    tokens = []
    sender = User.find_by_id(sender_id)
    if sender
      receiver_ids.each do |r_id|
        u = User.find_by_id(r_id)
        t = u.tokens.where(app_id: app_id)
        tokens |= t if !t.empty?
      end

      if !tokens.empty?
        p = PushService.new(:dev)
        p.connect
        tokens.each do |token|
          p.write(token.apns_token, {aps: {alert: "Your friend #{sender.nick} beat you!", badge: 1, sound: "default"}, other_meta: 10})
        end
        p.disconnect
      end
    end

    true
  end

end
