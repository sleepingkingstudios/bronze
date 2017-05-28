# lib/bronze/entities/primary_key.rb

require 'bronze/entities'
require 'bronze/entities/ulid'

module Bronze::Entities
  # Module for defining a primary key attribute on an entity.
  module PrimaryKey
    # Default attribute value for primary and foreign keys.
    KEY_DEFAULT = ->() { Bronze::Entities::Ulid.generate }

    # Attribute type for primary and foreign keys.
    KEY_TYPE = String

    def self.included other
      other.attribute :id,
        KEY_TYPE,
        :default   => KEY_DEFAULT,
        :read_only => true
    end # class method included

    # @!attribute [r] id
    #   A statistically unique entity identifier string. The id is generated
    #   automatically when the entity is initialized, and does not change
    #   thereafter.
    #
    #   Ids are sortable as strings in ascending order of generation, so
    #   entities can be sorted in order of creation by sorting the ids.
    #
    #   @return [String] The ULID identifier for the entity.
    #
    #   @see Bronze::Entities::Ulid.generate
  end # module
end # module
