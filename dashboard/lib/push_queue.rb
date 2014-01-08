class PushQueue
  class << self
    def add(pem_path, token, payload, in_sandbox)
      if token.length == 64
        entry = [pem_path, token, payload, in_sandbox]
        OKRedis.lpush('pn_queue_2', entry.to_json)
      end
    end
  end
end
