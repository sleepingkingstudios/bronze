# lib/bronze/entities/collections/entity_repository.rb

require 'bronze/entities/collections'
require 'bronze/entities/entity'
require 'bronze/entities/transforms/entity_transform'

module Bronze::Entities::Collections
  # Automatically generates an entity transform for a new collection when the
  # collection is referenced with an entity class.
  module EntityRepository
    private

    def build_transform collection_builder
      type = collection_builder.collection_type

      if entity_class?(type)
        return Bronze::Entities::Transforms::EntityTransform.new(type)
      end # if

      super
    end # method build_transform

    def entity_class? collection_type
      collection_type.is_a?(Class) && collection_type < Bronze::Entities::Entity
    end # method entity_class?
  end # module
end # module
