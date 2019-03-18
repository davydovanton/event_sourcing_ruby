require_relative './events.rb'
require_relative './event_producer.rb'
require_relative './event_store.rb'
require_relative './helpers.rb'
require_relative './projections.rb'

event_store = EventStore.new

event_store.subscribe(Events::FlavourRestocked) do |event|
  Logger.new(STDOUT).warn "Restock #{event.payload.last} of #{event.payload.first} flavour"
end

event_store.subscribe(Events::FlavourSold) do |event|
  Logger.new(STDOUT).info event.inspect
end

first_shop = 'first_shop_stream'
second_shop = 'second_shop_stream'

event_store.evolve(first_shop, Producers::RestockFlavour.new, flavour: :vanilla, count: 2)
event_store.evolve(second_shop, Producers::RestockFlavour.new, flavour: :vanilla, count: 3)

event_store.evolve(first_shop, Producers::SellFlavour.new, flavour: :vanilla)
event_store.evolve(first_shop, Producers::SellFlavour.new, flavour: :vanilla)
event_store.evolve(first_shop, Producers::SellFlavour.new, flavour: :vanilla)
event_store.evolve(first_shop, Producers::SellFlavour.new, flavour: :strawberry)
event_store.evolve(second_shop, Producers::SellFlavour.new, flavour: :vanilla)
event_store.evolve(second_shop, Producers::SellFlavour.new, flavour: :vanilla)
event_store.evolve(second_shop, Producers::SellFlavour.new, flavour: :vanilla)

event_store.evolve(first_shop, Producers::RestockFlavour.new, flavour: :strawberry, count: 1)
event_store.evolve(second_shop, Producers::RestockFlavour.new, flavour: :strawberry, count: 2)

event_store.evolve(first_shop, Producers::SellFlavour.new, flavour: :strawberry)
event_store.evolve(first_shop, Producers::SellFlavour.new, flavour: :strawberry)
event_store.evolve(second_shop, Producers::SellFlavour.new, flavour: :strawberry)
event_store.evolve(second_shop, Producers::SellFlavour.new, flavour: :strawberry)

first_shop_events = event_store.get_stream(first_shop) # => [...]

# #print_events from helpers 
puts "\n"
puts "Events for shop #{first_shop}:"
print_events first_shop_events

project = Projections::Project.new
base_state = {}
first_shop_sold = project.call(Projections::UpdateSoldFlavours.new, base_state, first_shop_events)

puts "\nSold state:"
p first_shop_sold

puts "\n\n"
puts '*' * 80
puts "\n\n"

second_shop_events = event_store.get_stream(second_shop) # => [...]

# #print_events from helpers 
puts "Events for shop #{second_shop}:"
print_events second_shop_events

project = Projections::Project.new
base_state = {}
second_shop_sold = project.call(Projections::UpdateSoldFlavours.new, base_state, second_shop_events)

puts "\nSold state:"
p second_shop_sold
