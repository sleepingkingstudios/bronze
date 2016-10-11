# lib/bronze/constraints/empty_constraint.rb

require 'bronze/constraints/constraint'

module Bronze::Constraints
  # Constraint that matches only nil and empty objects.
  class EmptyConstraint < Constraint
    # Error message for objects that match the constraint.
    EMPTY_ERROR = 'constraints.errors.empty'.freeze

    # Error message for objects that do not match the constraint.
    NOT_EMPTY_ERROR = 'constraints.errors.not_empty'.freeze

    private

    def build_errors _object
      super.add(NOT_EMPTY_ERROR)
    end # method build_errors

    def build_negated_errors _object
      super.add(EMPTY_ERROR)
    end # method build_errors

    def matches_object? object
      object.nil? || (object.respond_to?(:empty?) && object.empty?)
    end # method matches_object?
  end # class
end # module
