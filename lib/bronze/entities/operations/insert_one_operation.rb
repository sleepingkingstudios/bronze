require 'bronze/entities/operations/persistence_operation'

require 'cuprum/operation'

module Bronze::Entities::Operations
  # Operation for inserting the given entity into the repository.
  class InsertOneOperation < Cuprum::Operation
    include Bronze::Entities::Operations::PersistenceOperation

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
