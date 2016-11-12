# lib/bronze/entities/contracts/entity_contract.rb

require 'bronze/contracts/contract'
require 'bronze/entities/constraints/entity_constraint_builder'

module Bronze::Entities::Contracts
  # Contract with additional entity-specific constraint definitions.
  class EntityContract < Bronze::Contracts::Contract
    include Bronze::Entities::Constraints::EntityConstraintBuilder
  end # class
end # module
