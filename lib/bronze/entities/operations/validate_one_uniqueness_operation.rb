# lib/bronze/entities/operations/validate_one_uniqueness_operation.rb

require 'bronze/entities/operations/entity_operation'
require 'bronze/entities/operations/persistence_operation'
require 'bronze/operations/operation'

module Bronze::Entities::Operations
  # Validates the uniqueness of the given entity in the repository.
  class ValidateOneUniquenessOperation < Bronze::Operations::Operation
    include Bronze::Entities::Operations::EntityOperation
    include Bronze::Entities::Operations::PersistenceOperation

    # Checks the repository for entities matching the uniqueness criteria of the
    # given entity. The operation succeeds if there are no entities in the
    # collection that violate the entity's uniqueness constraints, or if the
    # entity does not support or define any uniqueness constraints.
    #
    # @param entity [Bronze::Entities::Entity] The entity whose uniqueness to
    #   check.
    #
    # @return [Bronze::Entities::Entity] The checked entity.
    def process entity
      return entity unless entity.respond_to?(:match_uniqueness)

      _, @errors = entity.match_uniqueness(collection)

      entity
    end # method process
  end # class
end # module
