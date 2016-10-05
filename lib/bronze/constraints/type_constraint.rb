# lib/bronze/constraints/type_constraint.rb

require 'bronze/constraints/constraint'

module Bronze::Constraints
  # Constraint that matches only the given object.
  class TypeConstraint < Constraint
    # Error message for objects that do not match the constraint.
    NOT_KIND_OF_ERROR = :not_kind_of

    # @param expected [Object] The expected object.
    def initialize expected, allow_nil: false
      @expected  = expected
      @allow_nil = allow_nil
    end # constructor

    private

    def build_errors _object
      super.add(NOT_KIND_OF_ERROR, @expected)
    end # method build_errors

    def matches_object? object
      return true if object.nil? && @allow_nil

      object.is_a?(@expected)
    end # method matches_object?
  end # class
end # module
