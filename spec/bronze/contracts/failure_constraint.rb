# spec/bronze/contracts/failure_constraint.rb

require 'bronze/contracts/constraint'

module Spec
  # An implementation of Bronze::Contracts::Constraint that does not match any
  # objects.
  class FailureConstraint < Bronze::Contracts::Constraint
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
