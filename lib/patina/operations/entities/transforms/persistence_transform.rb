# lib/patina/operations/entities/transforms/persistence_transform.rb

require 'bronze/entities/transforms/entity_transform'

require 'patina/operations/entities/transforms'

module Patina::Operations::Entities::Transforms
  # Maps an entity to a data hash using the entity's defined attributes, and
  # sets a denormalized entity's dirty and persistence states.
  class PersistenceTransform < Bronze::Entities::Transforms::EntityTransform
    # (see Bronze::Entities::Transforms::EntityTransform#denormalize)
    def denormalize attributes
      super.tap do |entity|
        entity.clean_attributes
        entity.persist
      end # tap
    end # method denormalize
  end # class
end # module
