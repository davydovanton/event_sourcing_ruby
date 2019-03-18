require_relative './events.rb'
require_relative './event_producer.rb'
require_relative './event_store.rb'
require_relative './helpers.rb'
require_relative './projections.rb'

event_store = EventStore.new

event_store.evolve(Producers::RestockFlavour.new, flavour: :vanilla, count: 2)

event_store.evolve(Producers::SellFlavour.new, flavour: :vanilla)
event_store.evolve(Producers::SellFlavour.new, flavour: :vanilla)
event_store.evolve(Producers::SellFlavour.new, flavour: :vanilla)
event_store.evolve(Producers::SellFlavour.new, flavour: :strawberry)

event_store.evolve(Producers::RestockFlavour.new, flavour: :strawberry, count: 1)

event_store.evolve(Producers::SellFlavour.new, flavour: :strawberry)
event_store.evolve(Producers::SellFlavour.new, flavour: :strawberry)

events = event_store.get # => [...]

# #print_events from helpers 
puts "Events:"
print_events events

project = Projections::Project.new
base_state = {}
sold = project.call(Projections::UpdateSoldFlavours.new, base_state, events)

puts "\nSold state:"
p sold
