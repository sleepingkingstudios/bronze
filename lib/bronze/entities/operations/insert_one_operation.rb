# lib/bronze/entities/operations/insert_one_operation.rb

require 'bronze/entities/operations/persistence_operation'

module Bronze::Entities::Operations
  # Operation for inserting the given entity into the repository.
  class InsertOneOperation < Bronze::Entities::Operations::PersistenceOperation
    # Inserts the given entity into the repository.
    #
    # @param entity [Bronze::Entities::Entity] The entity to insert into the
    #   repository.
    #
    # @return [Bronze::Entities::Entity] The inserted entity.
    #
    # @see Bronze::Collections::Collection#insert.
    def process entity
      _, errors = collection.insert(entity)

      if errors.empty?
        entity.persist if entity.respond_to?(:persist)
      else
        @errors[entity_name] = errors
      end # if-else

      entity
    end # method process
  end # class
end # module
