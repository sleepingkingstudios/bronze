# lib/patina/transforms/resource_transform.rb

require 'bronze/entities/transforms/entity_transform'

require 'patina/transforms'

module Patina::Transforms
  # Maps an entity to a data hash using the entity's defined attributes.
  class ResourceTransform < Bronze::Entities::Transforms::EntityTransform
    # (see Bronze::Entities::Transforms::EntityTransform#denormalize)
    def denormalize attributes
      super.tap do |entity|
        entity.clean_attributes
        entity.persist
      end # tap
    end # method denormalize
  end # class
end # module
