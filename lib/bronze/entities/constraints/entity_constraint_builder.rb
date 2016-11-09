# lib/bronze/entities/constraints/entity_constraint_builder.rb

require 'bronze/constraints/constraint_builder'
require 'bronze/entities/constraints/attribute_types_constraint'

module Bronze::Entities::Constraints
  # Domain-specific language for defining entity-specific constraints.
  module EntityConstraintBuilder
    include Bronze::Constraints::ConstraintBuilder

    def build_attribute_types_constraint _
      Bronze::Entities::Constraints::AttributeTypesConstraint.new
    end # method build_empty_constraint
  end # module
end # module
