=begin
  # Send myself a challenge from Todd:
  >
  > challenge = Challenge.new(sender_id: 119941, receiver_ids:[119979], leaderboard: Leaderboard.first, app: App.find(552), sandbox: true)
  > challenge.save
=end
class Challenge
  attr_accessor :sender_id, :receiver_ids, :leaderboard, :app, :challenge_uuid, :sandbox

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


  def cert
    sandbox ? app.sandbox_push_cert : app.production_push_cert
  end


  def save
    errors.push "sender_id is required"               unless sender_id
    errors.push "receiver_ids is required"            unless !receiver_ids.blank?
    errors.push "leaderboard is required"             unless leaderboard
    errors.push "app is required"                     unless app

    @sender = app.developer.users.find_by_id(sender_id)
    if @sender.nil?
      errors.push "Could not find a sender by that id"
    end

    if cert.nil?
      errors.push("You have not uploaded a push certificate for the #{sandbox ? 'sandbox' : 'production'} environment")
    end

    @safe_receivers = get_safe_receivers()
    if @safe_receivers.empty?
      errors.push("receiver_ids are not accessible.")
    end

    if errors.empty?
      if !enqueue()
        errors.push "Could not enqueue challenge"
      end
    end
    errors.empty?
  end


  protected
  def get_safe_receivers
    safe_receivers = []
    receiver_ids.each do |r_id|
      if app.developer.has_user?(r_id)
        safe_receivers << r_id
      end
    end
    safe_receivers
  end

  def get_receivers_tokens
    tokens = []
    @safe_receivers.each do |r_id|
      u = User.find_by_id(r_id)
      if u
        x = sandbox ? u.sandbox_tokens : u.tokens
        t = x.where(app_id: app.id).uniq_by(&:apns_token)
        tokens |= t if !t.empty?
      end
    end
    tokens
  end

  private
  def enqueue
    tokens = get_receivers_tokens()
    if !tokens.empty?
      tokens.each do |token|
        package = {aps: {alert: "#{@sender.nick} just beat your #{leaderboard.name} score.", sound: "default"}, challenge_uuid: challenge_uuid}
        entry = [cert.pem_path, token.apns_token, package, sandbox]
        OKRedis.connection.lpush(pn_queue_key, entry.to_json)
      end
    end
    true
  end

  def pn_queue_key
    'pn_queue_2'
  end

  def tokens_association
    sandbox ? :sandbox_tokens : :tokens
  end
end
