# lib/bronze/entities/operations/validate_one_operation.rb

require 'bronze/constraints/constraint'
require 'bronze/entities/operations/entity_operation'
require 'bronze/operations/operation'

module Bronze::Entities::Operations
  # Validates the given entity using the given contract, or with the entity
  # class's default contract.
  class ValidateOneOperation < Bronze::Operations::Operation
    include Bronze::Entities::Operations::EntityOperation

    DEFAULT_CONTRACT = Object.new.freeze
    private_constant :DEFAULT_CONTRACT

    # @param entity_class [Class] The class of entity this operation acts upon.
    # @param contract [Bronze::Contracts::Contract] The contract used to
    #   validate the entity. If no contract is provided, the operation will
    #   default to entity_class::Contract and then entity_class.contract.
    def initialize entity_class, contract = DEFAULT_CONTRACT
      @entity_class = entity_class
      @contract     = contract
    end # constructor

    # @return [Bronze::Contracts::Contract] The contract used to validate the
    #   entity. If no contract is provided, the operation will default to
    #   entity_class::Contract and then entity_class.contract.
    def contract
      return @contract unless @contract == DEFAULT_CONTRACT

      @contract = class_contract_constant || class_contract_method
    end # method contract

    # Validates the entity against the defined contract. The operation succeeds
    # if the validation has no errors or if no contract is defined.
    #
    # @param [Bronze::Entities::Entity] The entity to validate.
    #
    # @return [Bronze::Entities::Entity] The validated entity.
    def process entity
      return entity unless contract?

      result, errors = contract.match(entity)

      @errors[entity_name] = errors unless result

      entity
    end # method process

    private

    def class_contract_constant
      return nil unless entity_class.const_defined?(:Contract)

      contract = entity_class.const_get(:Contract)

      return nil unless contract.is_a?(Bronze::Constraints::Constraint)

      contract
    end # method class_contract_constant

    def class_contract_method
      return nil unless entity_class.respond_to?(:contract)

      contract = entity_class.send(:contract)

      return nil unless contract.is_a?(Bronze::Constraints::Constraint)

      contract
    end # method class_contract_method

    def contract?
      !contract.nil?
    end # method contract
  end # class
end # module
