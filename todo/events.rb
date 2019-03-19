require 'dry-struct'

module Types
  include Dry::Types.module
end

module Events
  class Base < Dry::Struct
    attribute :eid, Types::String.default { SecureRandom.uuid }
    attribute :created_at, Types::Time.default { Time.now }
    attribute :version, Types::String.default('v1')

    def self.payload_attributes(value = nil)
      if value
        @payload_attributes = Types::Hash.schema(value)
      else
        @payload_attributes || Types::Hash
      end
    end

    attribute :payload, payload_attributes

    def inspect
      "#{self.class.name} (#{version}) (#{eid}) payload: #{payload.inspect}"
    end
  end

  class TaskCreated < Base
    payload_attributes(
      id: Types::Integer,
      title: Types::String,
      status: Types::String.enum('open')
    )
  end

  class TaskUpdated < Base
    payload_attributes(
      id: Types::Integer,
      title: Types::String,
      status: Types::String.enum('open', 'completed')
    )
  end

  class NotExistedTaskCompleted < Base
    payload_attributes(
      id: Types::Integer
    )
  end
end
