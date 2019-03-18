# Event producer function
#
# Interface:
#   call : event list -> payload -> event list

module Producers
  class CreateTask
    def call(events, payload)
      [Events::TaskCreated.new(id: payload[:id], title: payload[:title], status: 'open')]
    end
  end

  class CompleteTask
    def initialize
      @project = Projections::Project.new
    end

    def call(events, payload)
      existed_ids = @project.call(Projections::TaskIds.new, {}, events)[:ids]

      if existed_ids.include?(payload[:id])
        [Events::TaskUpdated.new(id: payload[:id], status: 'completed')]
      else
        [Events::NotExistedTaskCompleted.new(id: payload[:id])]
      end
    end
  end

  class UpdateTaskTitle
    def initialize
      @project = Projections::Project.new
    end

    def call(events, payload)
      existed_ids = @project.call(Projections::TaskIds.new, {}, events)[:ids]

      if existed_ids.include?(payload[:id])
        [Events::TaskUpdated.new(id: payload[:id], title: payload[:title])]
      else
        [Events::NotExistedTaskCompleted.new(id: payload[:id])]
      end
    end
  end
end
