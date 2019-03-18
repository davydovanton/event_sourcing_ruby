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
  class EventSource
    def call
      SecureRandom.uuid
    end
  end

  def initialize
    @message_box = MessageBox.spawn(name: :message_box)
  end

  def get
    @message_box.ask(type: :get).value
  end

  def get_stream(event_source)
    @message_box.ask(type: :get_stream, event_source: event_source).value
  end

  def append(event_source, *events)
    events.each { |event| @message_box.tell(type: :append, event_source: event_source, event: event) }
  end

  def evolve(event_source, producer, payload)
    @message_box.ask(type: :evolve, event_source: event_source, producer: producer, payload: payload)
  end

private

  class MessageBox < Concurrent::Actor::Context
    def initialize
      @adapter = Adapters::InMemory.new
    end

    def on_message(message)
      case message[:type]
      when :get
        @adapter.get
      when :get_stream
        @adapter.get_stream(message[:event_source])
      when :append
        @adapter.append(message[:event_source], message[:event])
      when :evolve
        current_events = @adapter.get_stream(message[:event_source])
        new_events = message[:producer].call(current_events, message[:payload])
        @adapter.append_events(message[:event_source], new_events)
      else
        # pass to ErrorsOnUnknownMessage behaviour, which will just fail
        pass
      end
    end
  end

  module Adapters
    class InMemory
      def initialize
        @store = Hash.new { [] }
      end

      def get
        @store
      end

      def get_stream(source)
        @store[source]
      end

      def append(source, event)
        @store[source] << event
      end

      def append_events(source, events)
        @store[source] = @store[source] + events
      end
    end
  end
end
