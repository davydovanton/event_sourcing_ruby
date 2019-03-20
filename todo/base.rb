require_relative './../sync_complicated/event_store.rb'
require_relative './events.rb'
require_relative './producers.rb'
require_relative './projections.rb'

Sequel.extension :pg_json

# DB = Sequel.connect('postgres://localhost/todo_app_event_sourcing')
#
# DB.create_table :events do
#   String :eid, unique: true, null: false
#   String :event_name, null: false
#
#   String :stream, null: false
#   String :version, null: false
#   DateTime :created_at
#
#   jsonb :payload
# end

event_store = EventStore.new
task_stream = 'task_stream'

event_store.subscribe(Events::NotExistedTaskCompleted) do |event|
  Logger.new(STDOUT).warn event.inspect
end

event_store.evolve(task_stream, Producers::CreateTask.new, id: 1, title: 'Create producer for creating tasks')
event_store.evolve(task_stream, Producers::CompleteTask.new, id: 1)
event_store.evolve(task_stream, Producers::CreateTask.new, id: 2, title: 'Create producer for updating task title')
event_store.evolve(task_stream, Producers::CreateTask.new, id: 3, title: 'Allow to work with different tasks in same time')
event_store.evolve(task_stream, Producers::UpdateTaskTitle.new, id: 2, title: 'Update "Create producer for updating task title"')
event_store.evolve(task_stream, Producers::CompleteTask.new, id: 2)
event_store.evolve(task_stream, Producers::CompleteTask.new, id: 3)

events = event_store.get_stream(task_stream)

puts '*' * 80
puts events

project = Projections::Project.new

tasks_status = project.call(Projections::TotalAndCompletedTasks.new, {}, events)
all_tasks = project.call(Projections::AllTask.new, {}, events)

system("clear")

puts "Events for tasks:"
events.each { |e| puts "\t#{e.inspect}" }

puts "\nTasks state:"
puts "\t#{tasks_status}"

puts "\nTasks:"
(all_tasks[:tasks] || []).each { |task| puts "\t#{task}" }
