# lib/bronze/entities/operations/find_one_operation.rb

require 'bronze/entities/operations/entity_operation'
require 'bronze/entities/operations/persistence_operation'
require 'bronze/operations/operation'

module Bronze::Entities::Operations
  # Operation for retrieving the entity from a repository with the given primary
  # key.
  class FindOneOperation < Bronze::Operations::Operation
    include Bronze::Entities::Operations::EntityOperation
    include Bronze::Entities::Operations::PersistenceOperation

    # Queries the repository for the entity with the given primary key. The
    # operation succeeds if an entity is found the primary key, or fails if an
    # entity is not found for the primary key.
    #
    # @param primary_key [Object] The primary key to search for in the
    #   repository.
    #
    # @return [Bronze::Entities::Entity] The found entity.
    #
    # @see Bronze::Collections::Query#find.
    def process primary_key
      entity = collection.find(primary_key)

      unless entity
        @errors[entity_name].add(
          Bronze::Collections::Collection::Errors.record_not_found,
          :id => primary_key
        ) # end error
      end # unless

      entity
    end # method process
  end # class
end # module
