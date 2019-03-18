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

class EventStore
  def initialize
    @message_box = MessageBox.spawn(name: :message_box)
  end

  def get
    @message_box.ask(type: :get).value
  end

  def append(*events)
    events.each { |event| @message_box.tell(type: :append, event: event) }
  end

  def evolve(producer, payload)
    @message_box.ask(type: :evolve, producer: producer, payload: payload)
  end

private

  class MessageBox < Concurrent::Actor::Context
    def initialize
      @history = []
    end

    def on_message(message)
      case message[:type]
      when :get
        @history
      when :append
        @history << message[:event]
      when :evolve
        new_events = message[:producer].call(@history, message[:payload])
        @history = @history + new_events
      else
        # pass to ErrorsOnUnknownMessage behaviour, which will just fail
        pass
      end
    end
  end
end
