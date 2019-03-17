require_relative './event_store.rb'
require_relative './events.rb'
require_relative './helpers.rb'


module Domain

end

event_store = EventStore.new

event_store.append(Events::FlavourSold.new(:vanilla))
event_store.append(Events::FlavourSold.new(:vanilla))
event_store.append(Events::FlavourSold.new(:vanilla), Events::FlavourRestocked.new([:vanilla, 3]))

# #print_events from helpers 
print_events event_store.get # => [...]
