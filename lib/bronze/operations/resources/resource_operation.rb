# lib/bronze/operations/resources/resource_operation.rb

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/entities/contracts/entity_contract'
require 'bronze/entities/transforms/entity_transform'
require 'bronze/operations/resources'
require 'bronze/operations/repository_operation'

module Bronze::Operations::Resources
  # Shared functionality for operations on singular and plural resources.
  module ResourceOperation
    extend  SleepingKingStudios::Tools::Toolbox::Mixin
    include Bronze::Entities::Contracts::EntityContract
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

      alias_method :resource_contract, :contract

      # @return [Class] The class of the root resource.
      attr_reader :resource_class

      # @return [Boolean] True if a contract has been set or defined for the
      #   operation, otherwise false.
      def resource_contract?
        !!@contract
      end # method resource_contract?

      protected

      attr_writer :resource_class
    end # module

    # @param repository [Bronze::Collections::Repository] The repository used to
    #   persist and query the resource and any child resources.
    def initialize repository
      self.repository = repository
    end # method initialize

    # @return [Class] The class of the root resource.
    def resource_class
      self.class.resource_class
    end # method resource_class

    # @return [Bronze::Contracts::Contract] The contract (if any) for the root
    #   resource.
    def resource_contract
      return self.class.resource_contract if self.class.resource_contract?

      return nil unless resource_class

      if has_contract_const?(resource_class)
        resource_class::Contract.new
      elsif has_contract_method?(resource_class)
        resource_class.contract
      end # if-elsif
    end # method resource_contract

    # @return [Bronze::Collections::Collection] The collection used to persist
    #   and query the root resource.
    def resource_collection
      @resource_collection ||= begin
        transform = resource_transform_for(resource_class)

        repository.collection(resource_class, transform)
      end # begin-end
    end # method resource_collection

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

    # Matches the resource against the operation contract. If the operation
    # contract is not defined, matches against the contract for the operation's
    # resource class (if any).
    #
    # @param resource [Object] The resource to validate.
    #
    # @return Array[Boolean, Bronze::Errors::Errors] The result of the
    #   validation (true or false) and the generated errors.
    def resource_valid? resource
      return [true, []] if resource_contract.nil?

      resource_contract.match resource
    end # method resource_valid?

    private

    # rubocop:disable Style/PredicateName
    def has_contract_const? object
      object.const_defined?(:Contract) &&
        object.const_get(:Contract) < Bronze::Contracts::Contract
    end # method has_contract_const?

    def has_contract_method? object
      object.respond_to?(:contract) &&
        object.contract.is_a?(Bronze::Constraints::Constraint)
    end # method has_contract_method?
    # rubocop:enable Style/PredicateName

    def resource_transform_for resource_class
      Bronze::Entities::Transforms::EntityTransform.new resource_class
    end # method resource_transform_for
  end # module
end # module
