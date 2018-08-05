require 'bronze/entities/operations/base_operation'
require 'bronze/entities/operations/persistence_operation'

module Bronze::Entities::Operations
  # Operation for validating the given entity and, if valid, updating the
  # entity in the repository.
  class UpdateOneOperation < Bronze::Entities::Operations::BaseOperation
    include Bronze::Entities::Operations::PersistenceOperation

    private

    def add_missing_key_error
      result.errors[entity_name].add(
        Bronze::Collections::Collection::Errors.primary_key_missing,
        :key => :id
      )
    end

    def clean_entity_attributes entity
      entity.clean_attributes if entity.respond_to?(:clean_attributes)
    end

    # Updates the given entity in the repository.
    #
    # @param entity [Bronze::Entities::Entity] The entity to update in the
    #   repository.
    #
    # @return [Bronze::Entities::Entity] The updated entity.
    #
    # @see Bronze::Collections::Collection#update.
    def process entity
      unless entity
        add_missing_key_error

        return entity
      end

      success, errors = collection.update(entity.id, entity)

      result.errors[entity_name] = errors unless success

      clean_entity_attributes(entity) if success

      entity
    end
  end
end
