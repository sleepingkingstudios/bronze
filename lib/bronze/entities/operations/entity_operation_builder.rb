# lib/bronze/entities/operations/entity_operation_builder.rb

require 'bronze/entities/operations'
require 'bronze/operations/operation_class_builder'

operations_pattern = File.join(
  Bronze.lib_path, 'bronze', 'entities', 'operations', '*operation.rb'
) # end pattern
SleepingKingStudios::Tools::CoreTools.require_each(operations_pattern)

module Bronze::Entities::Operations
  # Builder class for accessing defined entity operations via a builder object.
  class EntityOperationBuilder < Bronze::Operations::OperationClassBuilder
    # @param entity_class [Class] The entity class to operate on. Defined entity
    #   operations will use this class to process the operations.
    def initialize entity_class
      @entity_class = entity_class

      super()
    end # constructor

    # Subclasses and defines helper methods for each entity operation.
    #
    # @see #entity_operation.
    def define_entity_operations
      entity_operation_names.each do |operation_name|
        const_name     = tools.string.camelize(operation_name)
        qualified_name = "Bronze::Entities::Operations::#{const_name}Operation"
        base_class     = Object.const_get(qualified_name)

        operation(operation_name, base_class)
      end # each
    end # method define_entity_operations

    private

    def build_subclass definition
      if definition < Bronze::Entities::Operations::EntityOperation
        return definition.subclass(@entity_class)
      end # if

      super
    end # method build_subclass

    def entity_operation_names # rubocop:disable Metrics/MethodLength
      [
        :assign_and_update_one,
        :assign_one,
        :build_and_insert_one,
        :build_one,
        :delete_one,
        :find_many,
        :find_matching,
        :find_one,
        :insert_one,
        :insert_one_without_validation,
        :update_one,
        :update_one_without_validation,
        :validate_one,
        :validate_one_uniqueness
      ] # end names
    end # method entity_operation_names
  end # class
end # module
