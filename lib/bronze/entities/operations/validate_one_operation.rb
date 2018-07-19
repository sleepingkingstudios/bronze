require 'bronze/entities/operations/contract_operation'
require 'bronze/entities/operations/entity_operation'

require 'cuprum/operation'

module Bronze::Entities::Operations
  # Validates the given entity using the given contract, or with the entity
  # class's default contract.
  class ValidateOneOperation < Cuprum::Operation
    include Bronze::Entities::Operations::ContractOperation

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
