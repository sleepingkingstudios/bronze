# lib/bronze/entities/operations/insert_one_without_validation_operation.rb

require 'bronze/entities/operations/persistence_operation'
require 'bronze/operations/operation'

module Bronze::Entities::Operations
  # Operation for inserting the given entity into the repository.
  class InsertOneWithoutValidationOperation < Bronze::Operations::Operation
    include Bronze::Entities::Operations::PersistenceOperation

    # Inserts the given entity into the repository.
    #
    # @param entity [Bronze::Entities::Entity] The entity to insert into the
    #   repository.
    #
    # @return [Bronze::Entities::Entity] The inserted entity.
    #
    # @see Bronze::Collections::Collection#insert.
    def process entity
      result, errors = collection.insert(entity)

      persist_entity(entity) if result

      @errors[entity_name] = errors unless result

      entity
    end # method process

    private

    def persist_entity entity
      entity.persist if entity.respond_to?(:persist)
    end # method persist_entity
  end # class
end # module
