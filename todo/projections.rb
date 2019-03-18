# Implementation of Projections (agregators)
#
# Interface for project:
#   call : projection -> base state -> events -> state
#
# Interface for each projection:
#   call : state -> event -> state
module Projections
  class TotalAndCompletedTasks
    def call(state, event)
      case event
      when Events::TaskCreated
        state[:total] = (state[:total] || 0) + 1
      when Events::TaskUpdated
        if event.payload[:status]
          state[:completed] = (state[:completed] || 0) + 1
        end
      end

      state
    end
  end

  class AllTask
    def call(state, event)
      case event
      when Events::TaskCreated
        state[:tasks] ||= []
        state[:tasks] << event.payload
      when Events::TaskUpdated
        completed_task = state[:tasks].select { |task| task[:id] == event.payload[:id] }.first
        completed_task = { **completed_task, **event.payload }

        state[:tasks] = state[:tasks].reject { |task| task[:id] == event.payload[:id] } + [completed_task]
      end

      state
    end
  end

  class TaskTitles
    def call(state, event)
      case event
      when Events::TaskCreated
        state[:titles] ||= []
        state[:titles] << event.payload[:title]
      end

      state
    end
  end

  class TaskIds
    def call(state, event)
      case event
      when Events::TaskCreated
        state[:ids] ||= []
        state[:ids] << event.payload[:id]
      end

      state
    end
  end
end
