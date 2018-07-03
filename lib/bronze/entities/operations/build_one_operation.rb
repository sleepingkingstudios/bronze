require 'bronze/entities/operations/entity_operation'

require 'cuprum/operation'

module Bronze::Entities::Operations
  # Operation for building a new entity with the contents of an attributes hash.
  class BuildOneOperation < Cuprum::Operation
    include Bronze::Entities::Operations::EntityOperation

    private

    # Builds an instance of the entity class and updates the attributes with
    # the contents of the given hash.
    #
    # @param attributes [Hash] The attributes and values to assign.
    #
    # @return [Bronze::Entities::Entity] The new entity.
    def process attributes = {}
      entity_class.new(attributes || {})
    end
  end
end
