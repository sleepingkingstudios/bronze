# spec/bronze/constraints/failure_constraint.rb

require 'bronze/constraints/constraint'

module Spec
  # An implementation of Bronze::Constraints::Constraint that does not match any
  # objects.
  class FailureConstraint < Bronze::Constraints::Constraint
    # Error message for objects that do not match the constraint.
    INVALID_ERROR = :invalid

    private

    def build_errors _object
      super.add(INVALID_ERROR)
    end # method build_errors

    def matches_object? _object
      false
    end # method matches_object?
  end # class
end # module
