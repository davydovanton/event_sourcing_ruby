require_relative './../sync_complicated/event_store.rb'
require_relative './../sync_complicated/projections.rb'
require_relative './events.rb'
require_relative './producers.rb'
require_relative './projections.rb'


event_store = EventStore.new
task_stream = 'task_stream'

event_store.evolve(task_stream, Producers::CreateTask.new, id: 1, title: 'Create producer for creating tasks')
event_store.evolve(task_stream, Producers::CompleteTask.new, id: 1)
event_store.evolve(task_stream, Producers::CreateTask.new, id: 2, title: 'Create producer for updating task title')
event_store.evolve(task_stream, Producers::CreateTask.new, id: 3, title: 'Allow to work with different tasks in same time')
event_store.evolve(task_stream, Producers::UpdateTaskTitle.new, id: 2, title: 'Update "Create producer for updating task title"')
event_store.evolve(task_stream, Producers::CompleteTask.new, id: 2)
event_store.evolve(task_stream, Producers::CompleteTask.new, id: 3)

events = event_store.get_stream(task_stream)

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
