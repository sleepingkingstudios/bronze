# lib/bronze/constraints/identity_constraint.rb

require 'bronze/constraints/constraint'

module Bronze::Constraints
  # Constraint that matches only the given object.
  class IdentityConstraint < Constraint
    # Error message for objects that do not match the constraint.
    NOT_IDENTICAL_TO_ERROR = :not_identical_to

    # @param expected [Object] The expected object.
    def initialize expected
      @expected = expected
    end # constructor

    private

    def build_errors _object
      super.add(NOT_IDENTICAL_TO_ERROR, @expected)
    end # method build_errors

    def matches_object? object
      @expected.equal?(object)
    end # method matches_object?
  end # class
end # module
