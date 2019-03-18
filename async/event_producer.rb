# Event producer function
#
# Interface:
#   call : event list -> payload -> event list

module Producers
  class SellFlavour
    def initialize
      @project = Projections::Project.new
      @base_state = Hash.new(0)
    end

    def call(events, payload)
      stock = @project.call(Projections::FlavoursInStock.new, @base_state, events)

      case stock[payload[:flavour]]
      when 0
        [Events::FlavourWentOutOfStock.new(payload[:flavour])]
      when 1
        [Events::FlavourSold.new(payload[:flavour]), Events::FlavourWentOutOfStock.new(payload[:flavour])]
      else
        [Events::FlavourSold.new(payload[:flavour])]
      end
    end
  end

  class RestockFlavour
    def call(events, payload)
      [Events::FlavourRestocked.new([payload[:flavour], payload[:count]])]
    end
  end
end
