# Implementation of Projections (agregators)
#
# Interface for project:
#   call : projection -> base state -> events -> state
#
# Interface for each projection:
#   call : state -> event -> state
module Projections
  class Project
    def call(projection, base_state, events)
      events.reduce(base_state) { |state, event| projection.call(state, event) }
    end
  end

  class UpdateSoldFlavours
    def call(state, event)
      case event
      when Events::FlavourSold
        state[event.payload] = (state[event.payload] || 0) + 1
        state
      else
        state
      end
    end
  end

  class FlavoursInStock
    def call(state, event)
      case event
      when Events::FlavourSold
        state[event.payload] = (state[event.payload] || 0) - 1
        state
      when Events::FlavourRestocked
        state[event.payload[0]] = (state[event.payload[0]] || 0) + event.payload[1]
        state
      else
        state
      end
    end
  end
end
