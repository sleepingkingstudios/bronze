# lib/bronze/contracts/not_nil_constraint.rb

require 'bronze/contracts/constraint'

module Bronze::Contracts
  # Constraint that matches all objects except for nil.
  class NotNilConstraint < Constraint
    # Error message for objects that do not match the constraint.
    NIL_ERROR = :nil

    private

    def build_errors _object
      super.add(NIL_ERROR)
    end # method build_errors

    def matches_object? object
      !object.nil?
    end # method matches_object?
  end # class
end # module
