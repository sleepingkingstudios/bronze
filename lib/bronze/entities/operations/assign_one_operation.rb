require 'bronze/entities/operations/base_operation'

module Bronze::Entities::Operations
  # Operation for updating the attributes of an entity with the contents of an
  # attributes hash.
  class AssignOneOperation < Bronze::Entities::Operations::BaseOperation
    private

    # Updates the attributes of the entity with the contents of the given hash.
    #
    # @param entity [Bronze::Entities::Entity] The entity whose attributes to
    #   update.
    # @param attributes [Hash] The attributes and values to assign.
    #
    # @return [Bronze::Entities::Entity] The entity with updated attributes.
    def process entity, attributes
      entity.assign(attributes)

      entity
    end
  end
end
