# lib/bronze/operations/operation_class_builder.rb

require 'bronze/operations/operation_builder'

module Bronze::Operations
  # Builder class for accessing defined operations via a builder object and the
  # respective operation classes via a definitions module.
  class OperationClassBuilder < Bronze::Operations::OperationBuilder
    def initialize
      const_set(:Definitions, Module.new)

      super()
    end # constructor

    private

    def build_subclass definition
      Class.new(definition)
    end # method build_subclass

    def constant_name method_name
      tools.string.camelize(method_name)
    end # method constant_name

    def define_operation method_name, definition
      if definition.is_a?(Class)
        const_name = constant_name(method_name)
        definition = define_subclass(const_name, definition)
      end # if

      super(method_name, definition)
    end # method define_operation

    def define_subclass const_name, definition
      qualified_name = "#{name}::#{const_name}"
      subclass       = build_subclass(definition)

      self::Definitions.const_set(const_name, subclass)

      %w[inspect name to_s].each do |method_name|
        subclass.define_singleton_method(method_name) { qualified_name }
      end # each

      subclass
    end # method define_subclass

    def extended object
      super

      object.send :include, self::Definitions if object.respond_to?(:include)
    end # method extended
  end # class
end # module
