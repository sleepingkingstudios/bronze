# lib/bronze/entities/operations/entity_operation_builder.rb

require 'bronze/entities/operations'
require 'bronze/operations/operation_builder'

operations_pattern = File.join(
  Bronze.lib_path, 'bronze', 'entities', 'operations', '*operation.rb'
) # end pattern
SleepingKingStudios::Tools::CoreTools.require_each(operations_pattern)

module Bronze::Entities::Operations
  # Builder class for accessing defined entity operations via a builder object.
  class EntityOperationBuilder < Bronze::Operations::OperationBuilder
    # @param entity_class [Class] The entity class to operate on. Defined entity
    #   operations will use this class to process the operations.
    def initialize entity_class
      const_set(:Definitions, Module.new)

      @entity_class = entity_class

      super()
    end # constructor

    # @api private
    def extended klass
      super

      klass.send :include, self::Definitions
    end # method extended

    # Subclasses and defines helper methods for each entity operation.
    #
    # @see #entity_operation.
    def define_entity_operations
      entity_operation_names.each do |operation_name|
        const_name     = tools.string.camelize(operation_name)
        qualified_name = "Bronze::Entities::Operations::#{const_name}Operation"
        base_class     = Object.const_get(qualified_name)

        entity_operation(operation_name, base_class)
      end # each
    end # method define_entity_operations

    # Creates a subclass of the given entity operation with the set entity
    # class and sets it as a constant on the module, and defines a helper method
    # that wraps the operation subclass. The method will instantiate the
    # operation subclass, pass any parameters to and execute the operation
    # instance, and return the called operation.
    #
    # @overload operation(name, definition)
    #   @param name [String, Symbol] The name of the helper method.
    #   @param definition [Class] The operation class.
    #
    # @overload operation(definition)
    #   @param definition [Class] The operation class. The name of the helper
    #     method will be derived from the class name.
    #
    # @return [Operation] The called operation.
    def entity_operation name_or_definition, definition = nil
      if definition
        method_name = name_or_definition
      else
        method_name = operation_name(name_or_definition)
        definition  = name_or_definition
      end # if-else

      const_name = constant_name(method_name)
      subclass   = define_subclass(const_name, definition)

      operation(method_name, subclass)
    end # method entity_operation

    private

    def constant_name method_name
      tools.string.camelize(method_name)
    end # method constant_name

    def define_subclass const_name, definition
      qualified_name = "#{name}::#{const_name}"
      subclass       = definition.subclass(@entity_class)

      self::Definitions.const_set(const_name, subclass)

      %w(inspect name to_s).each do |method_name|
        subclass.define_singleton_method(method_name) { qualified_name }
      end # each

      subclass
    end # method define_subclass

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
