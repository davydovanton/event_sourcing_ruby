module Events
  class Base
    attr_reader :payload

    def initialize(payload)
      @payload = payload
    end

    def inspect
      "Events::#{self.class.name} payload: #{payload.inspect}"
    end
  end

  class FlavourSold < Base
  end

  class FlavourRestocked < Base
  end
end
