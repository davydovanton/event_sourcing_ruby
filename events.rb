module Events
  class Base
    attr_reader :payload

    def initialize(payload)
      @payload = payload
    end
  end

  class FlavourSold < Base
  end

  class FlavourRestocked < Base
  end
end
