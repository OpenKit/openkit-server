require 'json'

module ApplePush
  class Note
    def initialize(token, payload)
      @token = token
      @payload = payload
    end

    def packed
      pt = [@token].pack('H*')
      pm = @payload.to_json
      [0, 0, 32, pt, 0, pm.size, pm].pack("ccca*cca*")
    end
  end
end
