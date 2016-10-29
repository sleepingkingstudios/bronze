# lib/bronze/constraints/identity_constraint.rb

require 'bronze/constraints/constraint'

module Bronze::Constraints
  # Constraint that matches only the given object.
  class IdentityConstraint < Constraint
    # Error message for objects that match the constraint.
    IDENTICAL_TO_ERROR = 'constraints.errors.messages.identical_to'.freeze

    # Error message for objects that do not match the constraint.
    NOT_IDENTICAL_TO_ERROR =
      'constraints.errors.messages.not_identical_to'.freeze

    # @param expected [Object] The expected object.
    def initialize expected
      @expected = expected
    end # constructor

    # @return [Object] The expected object.
    attr_reader :expected
    alias_method :value, :expected

    private

    def build_errors _object
      super.add(NOT_IDENTICAL_TO_ERROR, :value => @expected)
    end # method build_errors

    def build_negated_errors _object
      super.add(IDENTICAL_TO_ERROR, :value => @expected)
    end # method build_errors

    def matches_object? object
      @expected.equal?(object)
    end # method matches_object?
  end # class
end # module
