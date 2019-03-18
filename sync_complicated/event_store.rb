# Simple implementation of event store
#
# Interface:
#   Get : unit -> event list
#   Append : event list -> unit
#   Evolve : event producer (event) -> unit
#
# Based on Concurrent/Actor

require 'concurrent'
require 'concurrent/actor'
require 'securerandom'

class EventStore
  def initialize
    @message_box = MessageBox.spawn(name: :message_box)
  end

  def get
    @message_box.ask(type: :get).value
  end

  def get_stream(stream)
    @message_box.ask(type: :get_stream, stream: stream).value
  end

  def append(stream, *events)
    events.each { |event| @message_box.tell(type: :append, stream: stream, event: event) }
  end

  def evolve(stream, producer, payload)
    @message_box.ask(type: :evolve, stream: stream, producer: producer, payload: payload)
  end

  def subscribe(event_class, &block)
    @message_box.ask(type: :subscribe, event_class: event_class, subscriber_block: block)
  end

private

  class Subscriber
    def initialize(event_class, block)
      @event_class = event_class
      @block = block
    end

    def call(event)
      @block.call(event) if @event_class.name == event.class.name
    end
  end

  class MessageBox < Concurrent::Actor::Context
    def initialize
      @adapter = Adapters::InMemory.new
      @subscribers = []
    end

    def on_message(message)
      case message[:type]
      when :get
        @adapter.get
      when :get_stream
        @adapter.get_stream(message[:stream])
      when :append
        @adapter.append(message[:stream], message[:event])

        @subscribers.each { |s| s.call(message[:event]) }
      when :evolve
        current_events = @adapter.get_stream(message[:stream])
        new_events = message[:producer].call(current_events, message[:payload])
        @adapter.append_events(message[:stream], new_events)

        new_events.each { |event| @subscribers.each { |s| s.call(event) } }
      when :subscribe
        @subscribers << Subscriber.new(message[:event_class], message[:subscriber_block])
      else
        # pass to ErrorsOnUnknownMessage behaviour, which will just fail
        pass
      end
    end
  end

  module Adapters
    class InMemory
      def initialize
        @store = Concurrent::Hash.new { [] }
      end

      def get
        @store
      end

      def get_stream(stream)
        @store[stream]
      end

      def append(stream, event)
        @store[stream] << event
      end

      def append_events(stream, events)
        @store[stream] = @store[stream] + events
      end
    end
  end
end
