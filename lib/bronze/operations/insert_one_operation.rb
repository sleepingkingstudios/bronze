require 'bronze/operations/base_operation'
require 'bronze/operations/persistence_operation'

require 'cuprum/operation'

module Bronze::Operations
  # Operation for inserting the given entity into the repository.
  class InsertOneOperation < Bronze::Operations::BaseOperation
    include Bronze::Operations::PersistenceOperation

    private

    # Inserts the given entity into the repository.
    #
    # @param entity [Bronze::Entities::Entity] The entity to insert into the
    #   repository.
    #
    # @return [Bronze::Entities::Entity] The inserted entity.
    #
    # @see Bronze::Collections::Collection#insert.
    def process(entity)
      success, errors = collection.insert(entity)

      persist_entity(entity) if success

      result.errors[entity_name] = errors unless success

      entity
    end
  end
end
