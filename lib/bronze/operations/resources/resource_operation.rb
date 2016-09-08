# lib/bronze/operations/resources/resource_operation.rb

require 'bronze/operations/resources'

module Bronze::Operations::Resources
  # Shared functionality for operations on singular and plural resources.
  module ResourceOperation
    # Class methods to define when including ResourceOperation in a class.
    module ClassMethods
      # Creates a new subclass of the including class with the given resource
      # class.
      #
      # @param resource_class [Class] The class of the root resource.
      def [] resource_class
        generated_name = "#{name}[#{resource_class.name}]"

        subclass = Class.new(self)
        subclass.resource_class = resource_class
        subclass.define_singleton_method :name, ->() { generated_name }
        subclass
      end # class method []

      # @return [Class] The class of the root resource.
      attr_reader :resource_class

      protected

      attr_writer :resource_class
    end # module

    # @api private
    def self.included other
      other.extend ClassMethods

      super
    end # class method included

    # @return [Class] The class of the root resource.
    def resource_class
      self.class.resource_class
    end # method resource_class

    # @return [String] The name of the root resource.
    def resource_name
      @resource_name ||= begin
        return nil if resource_class.nil?

        tools = ::SleepingKingStudios::Tools::StringTools
        name  = resource_class.name.split('::').last
        name  = tools.pluralize(name)

        tools.underscore(name)
      end # begin
    end # method resource_name
  end # module
end # module
