# lib/bronze/entities/entity.rb

require 'bronze/entities/attributes'
require 'bronze/entities/attributes/attribute_builder'

require 'bronze/entities/ulid'

module Bronze::Entities
  # Base class for implementing data entities, which store information about
  # business objects without making assumptions about or tying the
  # implementation to any specific framework or data repository.
  class Entity
    include Bronze::Entities::Attributes

    # Default attribute value for primary and foreign keys.
    KEY_DEFAULT = ->() { Bronze::Entities::Ulid.generate }

    # Attribute type for primary and foreign keys.
    KEY_TYPE = String

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
    attribute :id,
      KEY_TYPE,
      :default   => KEY_DEFAULT,
      :read_only => true
  end # class
end # module
