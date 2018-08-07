require 'bronze/operations/base_operation'

module Bronze::Operations
  # Operation for building a new entity with the contents of an attributes hash.
  class BuildOneOperation < Bronze::Operations::BaseOperation
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
