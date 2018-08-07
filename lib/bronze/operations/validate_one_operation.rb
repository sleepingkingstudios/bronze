require 'bronze/operations/base_operation'
require 'bronze/operations/contract_operation'

module Bronze::Operations
  # Validates the given entity using the given contract, or with the entity
  # class's default contract.
  class ValidateOneOperation < Bronze::Operations::BaseOperation
    include Bronze::Operations::ContractOperation

    private

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
