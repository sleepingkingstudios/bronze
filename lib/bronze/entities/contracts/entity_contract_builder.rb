# lib/bronze/entities/contracts/entity_contract_builder.rb

require 'bronze/contracts/contract_builder'
require 'bronze/entities/constraints/attribute_types_constraint'
require 'bronze/entities/contracts'

module Bronze::Entities::Contracts
  # Builder object for creating and extending contract objects for entities with
  # a convenient DSL.
  class EntityContractBuilder < Bronze::Contracts::ContractBuilder
    def constrain_attribute_types
      contract.add_constraint build_constraint(:attribute_types, {})
    end # method constrain_attribute_types

    private

    def build_attribute_types_constraint _
      Bronze::Entities::Constraints::AttributeTypesConstraint.new
    end # method build_attribute_types_constraint
  end # class
end # module
