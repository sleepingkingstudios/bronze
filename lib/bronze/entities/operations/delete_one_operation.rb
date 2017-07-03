# lib/bronze/entities/operations/delete_one_operation.rb

require 'bronze/entities/operations/persistence_operation'
require 'bronze/operations/operation'

module Bronze::Entities::Operations
  # Operation for deleting an new entity from a repository.
  class DeleteOneOperation < Bronze::Operations::Operation
    include Bronze::Entities::Operations::PersistenceOperation

    # Finds and deletes the entity with the given primary key from the
    # repository. The operation succeeds if the delete action does not return
    # any errors, and fails if the delete action returns one or more errors
    # (typically if the requested entity or entity with the requested primary
    # key is not found in the repository).
    #
    # @overload process(entity)
    #   @param entity [Bronze::Entities::Entity] The entity to remove from the
    #     repository.
    #
    # @overload process(primary_key)
    #   @param primary_key [Object] The primary key of the entity to remove from
    #     the repository.
    #
    # @return [nil] Always returns nil.
    def process entity_or_entity_id
      id = entity_id(entity_or_entity_id)

      _, errors = collection.delete(id)

      @errors[entity_name] = errors unless errors.empty?

      nil
    end # method process

    private

    def entity_id entity_or_entity_id
      if entity_or_entity_id.respond_to?(:id)
        entity_or_entity_id.id
      else
        entity_or_entity_id
      end # if-else
    end # method entity_id
  end # class
end # module
