require 'securerandom'

module Events
  class Base
    attr_reader :payload, :eid, :created_at

    def initialize(payload)
      @eid = SecureRandom.uuid
      @payload = payload
      @created_at = Time.now
      # @event_source = event_source
    end

    def inspect
      "#{self.class.name} (#{eid}) payload: #{payload.inspect}"
    end
  end

  class FlavourSold < Base
  end

  class FlavourRestocked < Base
  end

  class FlavourWentOutOfStock < Base
  end
end
