# lib/bronze/entities/collections/entities_collection.rb

require 'bronze/collections/collection'
require 'bronze/entities/collections'
require 'bronze/entities/entity'
require 'bronze/entities/transforms/entity_transform'

module Bronze::Entities::Collections
  # A module for a collection that stores serialized entities. It provides some
  # syntactic sugar for intelligently selecting transforms based on the entity
  # class.
  module EntityCollection
    # @param entity_class_or_transform [Class, Bronze::Transforms::Transform] If
    #   an entity class, will create a transform for the entity class; otherwise
    #   will set the collection's transform to the given transform.
    def initialize entity_class_or_transform
      @entity_class, transform = extract_entity_class(entity_class_or_transform)

      super transform
    end # constructor

    # @return [Class] The entity class data will be deserialized to.
    attr_reader :entity_class

    private

    def default_transform_for entity_class
      Bronze::Entities::Transforms::EntityTransform.new(entity_class)
    end # method default_transform_for

    def entity_class? obj
      return false unless obj.is_a?(Class)

      obj < Bronze::Entities::Entity
    end # method entity_class

    def extract_entity_class entity_class_or_transform
      if entity_class?(entity_class_or_transform)
        entity_class = entity_class_or_transform
        transform    = default_transform_for entity_class
      else
        transform = entity_class_or_transform

        if transform.respond_to?(:entity_class)
          entity_class = transform.entity_class
        end # if
      end # if-else

      [entity_class, transform]
    end # method extract_entity_class
  end # module
end # module
