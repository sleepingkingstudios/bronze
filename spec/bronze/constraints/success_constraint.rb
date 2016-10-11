# spec/bronze/constraints/success_constraint.rb

require 'bronze/constraints/constraint'

module Spec
  # An implementation of Bronze::Constraints::Constraint that matches all
  # objects.
  class SuccessConstraint < Bronze::Constraints::Constraint
    # Error message for objects that do not match the constraint.
    VALID_ERROR = 'constraints.errors.valid_object'.freeze

    private

    def build_negated_errors _object
      super.add(VALID_ERROR)
    end # method build_errors

    def matches_object? _object
      true
    end # method matches_object?
  end # class
end # module
