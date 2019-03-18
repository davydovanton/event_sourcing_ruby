require_relative './../sync_complicated/events.rb'
require_relative './../sync_complicated/event_store.rb'
require_relative './../sync_complicated/projections.rb'
require_relative './events.rb'
require_relative './producers.rb'
require_relative './projections.rb'

def display_state(task_stream = TASK_STREAM, project = Projections::Project.new)
  events = EVENT_STORE.get_stream(task_stream)

  tasks_status = project.call(Projections::TotalAndCompletedTasks.new, {}, events)
  all_tasks = project.call(Projections::AllTask.new, {}, events)

  system("clear")

  puts "Events for tasks:"
  events.each { |e| puts "\t#{e.inspect}" }

  puts "\nTasks state:"
  puts "\t#{tasks_status}"

  puts "\nTasks:"
  (all_tasks[:tasks] || []).each { |task| puts "\t#{task}" }
end

EVENT_STORE = EventStore.new
TASK_STREAM = 'task_stream'

display_state
sleep(3)

EVENT_STORE.evolve(TASK_STREAM, Producers::CreateTask.new, id: 1, title: 'Create producer for creating tasks')
display_state
sleep(3)

EVENT_STORE.evolve(TASK_STREAM, Producers::CompleteTask.new, id: 1)
display_state
sleep(3)

EVENT_STORE.evolve(TASK_STREAM, Producers::CreateTask.new, id: 2, title: 'Create producer for updating task title')
display_state
sleep(3)

EVENT_STORE.evolve(TASK_STREAM, Producers::UpdateTaskTitle.new, id: 2, title: 'Update "Create producer for updating task title"')
display_state
sleep(3)

EVENT_STORE.evolve(TASK_STREAM, Producers::CompleteTask.new, id: 2)
display_state
sleep(3)
