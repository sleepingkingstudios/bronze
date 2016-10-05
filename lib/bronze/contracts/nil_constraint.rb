# lib/bronze/contracts/nil_constraint.rb

require 'bronze/contracts/constraint'

module Bronze::Contracts
  # Constraint that matches only nil.
  class NilConstraint < Constraint
    # Error message for objects that do not match the constraint.
    NOT_NIL_ERROR = :not_nil

    private

    def build_errors _object
      super.add(NOT_NIL_ERROR)
    end # method build_errors

    def matches_object? object
      object.nil?
    end # method matches_object?
  end # class
end # module
