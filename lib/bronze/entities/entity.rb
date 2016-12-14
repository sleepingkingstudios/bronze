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
      String,
      :default   => ->() { Bronze::Entities::Ulid.generate },
      :read_only => true
  end # class
end # module
