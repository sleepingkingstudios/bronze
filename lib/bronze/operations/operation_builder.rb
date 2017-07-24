# lib/bronze/operations/operation_builder.rb

require 'bronze/operations'

module Bronze::Operations
  # Builder class for accessing defined operations via a builder object.
  class OperationBuilder < Module
    def initialize
      super

      extend self
    end # constructor

    # Defines a helper method that wraps the given operation. The method will
    # instantiate the operation class with any given parameters and return the
    # operation instance.
    #
    # @overload operation(name, definition)
    #   @param name [String, Symbol] The name of the helper method.
    #   @param definition [Class] The operation class.
    #
    # @overload operation(definition)
    #   @param definition [Class] The operation class. The name of the helper
    #     method will be derived from the class name.
    #
    # @overload operation(name, &block)
    #   @param name [String, Symbol] The name of the helper method.
    #   @yield A block defining the method body. The block should instantiate
    #     and return an operation instance.
    #
    # @return [Operation] The called operation.
    def operation name_or_definition, definition = nil, &defn_block
      if definition
        define_operation(name_or_definition, definition)
      elsif defn_block
        define_operation(name_or_definition, defn_block)
      else
        define_operation(operation_name(name_or_definition), name_or_definition)
      end # if
    end # method operation

    private

    def define_operation method_name, definition
      define_method(method_name) do |*args, &block|
        if definition.is_a?(Proc)
          definition.call(*args, &block)
        else
          definition.new(*args, &block)
        end # if-else
      end # method method_name
    end # method define_operation

    def operation_name definition
      name = definition.name.split('::').last.sub(/Operation$/, '')

      tools.string.underscore(name)
    end # method operation_name

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end # method tools
  end # class
end # module
