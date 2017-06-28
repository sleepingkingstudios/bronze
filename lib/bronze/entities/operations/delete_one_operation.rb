# lib/bronze/entities/operations/delete_one_operation.rb

require 'bronze/entities/operations/persistence_operation'

module Bronze::Entities::Operations
  # Operation for deleting an new entity from a repository.
  class DeleteOneOperation < Bronze::Entities::Operations::PersistenceOperation
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
