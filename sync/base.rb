require_relative './event_store.rb'
require_relative './events.rb'
require_relative './helpers.rb'
require_relative './projections.rb'

event_store = EventStore.new

event_store.append(Events::FlavourRestocked.new([:vanilla, 3]))
event_store.append(Events::FlavourSold.new(:vanilla))
event_store.append(Events::FlavourSold.new(:vanilla))
event_store.append(Events::FlavourSold.new(:strawberry))
event_store.append(Events::FlavourSold.new(:vanilla))

events = event_store.get # => [...]

# #print_events from helpers 
puts "Events:"
print_events events

project = Projections::Project.new
base_state = {}
sold = project.call(Projections::UpdateSoldFlavours.new, base_state, events)

puts "\nSold state:"
p sold
