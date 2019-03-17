# Simple implementation of event store
#
# Interface:
#   Get : unit -> event list
#   Append : event list -> unit
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
    events.each { |event| @message_box.tell(type: :append, value: event) }
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
        @history << message[:value]
      else
        # pass to ErrorsOnUnknownMessage behaviour, which will just fail
        pass
      end
    end
  end
end
