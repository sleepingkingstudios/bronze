# lib/bronze/contracts/equality_constraint.rb

require 'bronze/contracts/constraint'

module Bronze::Contracts
  # Constraint that matches only the given object.
  class EqualityConstraint < Constraint
    # Error message for objects that do not match the constraint.
    NOT_EQUAL_TO_ERROR = :not_equal_to

    # @param expected [Object] The expected object.
    def initialize expected
      @expected = expected
    end # constructor

    private

    def build_errors _object
      super.add(NOT_EQUAL_TO_ERROR, @expected)
    end # method build_errors

    def matches_object? object
      @expected == object
    end # method matches_object?
  end # class
end # module
