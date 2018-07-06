# lib/bronze/entities/operations/assign_one_operation.rb

require 'bronze/entities/operations/entity_operation'

require 'cuprum/operation'

module Bronze::Entities::Operations
  # Operation for updating the attributes of an entity with the contents of an
  # attributes hash.
  class AssignOneOperation < Cuprum::Operation
    include Bronze::Entities::Operations::EntityOperation

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
