# lib/bronze/entities/persistence.rb

require 'bronze/entities'

module Bronze::Entities
  # Module for tracking the persistence state of entities.
  module Persistence
    # @param attributes [Hash] The default attributes with which to initialize
    #   the entity. Defaults to an empty hash.
    def initialize _attributes = {}
      @persisted = false

      super
    end # constructor

    # Marks the entity as persiste.
    def persist
      @persisted = true
    end # method persist

    # @return [Boolean] True if the entity has been marked as persisted,
    #   otherwise false.
    def persisted?
      @persisted
    end # method persisted?
  end # module
end # module
