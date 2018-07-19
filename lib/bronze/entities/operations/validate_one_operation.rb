require 'bronze/constraints/constraint'
require 'bronze/entities/operations/entity_operation'

require 'cuprum/operation'

module Bronze::Entities::Operations
  # Validates the given entity using the given contract, or with the entity
  # class's default contract.
  class ValidateOneOperation < Cuprum::Operation
    include Bronze::Entities::Operations::EntityOperation

    DEFAULT_CONTRACT = Object.new.freeze
    private_constant :DEFAULT_CONTRACT

    # @param entity_class [Class] The class of entity this operation acts upon.
    # @param contract [Bronze::Constraints::Constraint] The contract to validate
    #   entities against. Defaults to no contract, in which case the entity will
    #   be validated using the contract defined for the entity class, if any.
    def initialize(*args, contract: DEFAULT_CONTRACT, **kwargs)
      # RUBY_VERSION: Required below 2.5
      args << kwargs unless kwargs.empty?

      super(*args)

      @contract = contract
    end

    # @return [Bronze::Contracts::Contract] The contract used to validate the
    #   entity. If no contract is provided, the operation will default to
    #   entity_class::Contract and then entity_class.contract.
    def contract
      return @contract unless @contract == DEFAULT_CONTRACT

      @contract = class_contract_constant || class_contract_method
    end

    private

    def class_contract_constant
      return nil unless entity_class.const_defined?(:Contract)

      contract = entity_class.const_get(:Contract)

      return contract if contract.is_a?(Bronze::Constraints::Constraint)

      if contract.is_a?(Class) && contract < Bronze::Constraints::Constraint
        return contract.new
      end

      nil
    end

    def class_contract_method
      return nil unless entity_class.respond_to?(:contract)

      contract = entity_class.send(:contract)

      return contract if contract.is_a?(Bronze::Constraints::Constraint)

      if contract.is_a?(Class) && contract < Bronze::Constraints::Constraint
        return contract.new
      end

      nil
    end

    def contract?
      !contract.nil?
    end

    # Validates the entity against the defined contract. The operation succeeds
    # if the validation has no errors or if no contract is defined.
    #
    # @param [Bronze::Entities::Entity] The entity to validate.
    #
    # @return [Bronze::Entities::Entity] The validated entity.
    def process entity
      return entity unless contract?

      success, errors = contract.match(entity)

      result.errors[entity_name] = errors unless success

      entity
    end
  end
end
