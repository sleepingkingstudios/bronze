# lib/bronze/constraints/nil_constraint.rb

require 'bronze/constraints/constraint'

module Bronze::Constraints
  # Constraint that matches only nil.
  class NilConstraint < Constraint
    # Error message for objects that match the constraint.
    NIL_ERROR = 'constraints.errors.messages.nil'.freeze

    # Error message for objects that do not match the constraint.
    NOT_NIL_ERROR = 'constraints.errors.messages.not_nil'.freeze

    private

    def build_errors _object
      super.add(NOT_NIL_ERROR)
    end # method build_errors

    def build_negated_errors _object
      super.add(NIL_ERROR)
    end # method build_errors

    def matches_object? object
      object.nil?
    end # method matches_object?
  end # class
end # module
