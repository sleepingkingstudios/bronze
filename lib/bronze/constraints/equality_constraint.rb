# lib/bronze/constraints/equality_constraint.rb

require 'bronze/constraints/constraint'

module Bronze::Constraints
  # Constraint that matches only the given object.
  class EqualityConstraint < Constraint
    # Error message for objects that match the constraint.
    EQUAL_TO_ERROR = 'constraints.errors.equal_to'.freeze

    # Error message for objects that do not match the constraint.
    NOT_EQUAL_TO_ERROR = 'constraints.errors.not_equal_to'.freeze

    # @param expected [Object] The expected object.
    def initialize expected
      @expected = expected
    end # constructor

    private

    def build_errors _object
      super.add(NOT_EQUAL_TO_ERROR, @expected)
    end # method build_errors

    def build_negated_errors _object
      super.add(EQUAL_TO_ERROR, @expected)
    end # method build_errors

    def matches_object? object
      @expected == object
    end # method matches_object?
  end # class
end # module
