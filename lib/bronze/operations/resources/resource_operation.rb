# lib/bronze/operations/resources/resource_operation.rb

require 'sleeping_king_studios/tools/toolbox/mixin'
require 'bronze/operations/resources'
require 'bronze/operations/repository_operation'

module Bronze::Operations::Resources
  # Shared functionality for operations on singular and plural resources.
  module ResourceOperation
    extend  SleepingKingStudios::Tools::Toolbox::Mixin
    include Bronze::Operations::RepositoryOperation

    # Class methods to define when including ResourceOperation in a class.
    module ClassMethods
      # Creates a new subclass of the including class with the given resource
      # class.
      #
      # @param resource_class [Class] The class of the root resource.
      def [] resource_class
        generated_name = "#{name}[#{resource_class.name}]"
        name_method    = ->() { super() || generated_name }

        subclass = Class.new(self)
        subclass.resource_class = resource_class
        subclass.define_singleton_method :name, name_method
        subclass.define_singleton_method :to_s, name_method
        subclass
      end # class method []

      # @return [Class] The class of the root resource.
      attr_reader :resource_class

      protected

      attr_writer :resource_class
    end # module

    # @param repository [Bronze::Collections::Repository] The repository used to
    #   persist and query the resource and any child resources.
    def initialize repository
      self.repository = repository
    end # method initialize

    # @return [Bronze::Collections::Collection] The collection used to persist
    #   and query the root resource.
    def collection
      @collection ||= repository.collection(resource_class)
    end # method collection

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
