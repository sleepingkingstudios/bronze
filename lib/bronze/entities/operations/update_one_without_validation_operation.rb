# lib/bronze/entities/operations/update_one_without_validation_operation.rb

require 'bronze/entities/operations/persistence_operation'
require 'bronze/operations/operation'

module Bronze::Entities::Operations
  # Operation for updating the given entity in the repository.
  class UpdateOneWithoutValidationOperation < Bronze::Operations::Operation
    include Bronze::Entities::Operations::PersistenceOperation

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
      end # unless

      result, errors = collection.update(entity.id, entity)

      @errors[entity_name] = errors unless result

      clean_entity_attributes(entity) if result

      entity
    end # method process

    private

    def add_missing_key_error
      @errors[entity_name].add(
        Bronze::Collections::Collection::Errors.primary_key_missing,
        :key => :id
      ) # end error
    end # method add_missing_key_error

    def clean_entity_attributes entity
      entity.clean_attributes if entity.respond_to?(:clean_attributes)
    end # method clean_entity_attributes
  end # module
end # module
