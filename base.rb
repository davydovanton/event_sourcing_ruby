require_relative './event_store.rb'

event_store = EventStore.new

event_store.append('fist event', 'second event')
p event_store.get # => ["fist event", "second event"]
