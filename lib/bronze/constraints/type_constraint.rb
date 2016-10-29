# lib/bronze/constraints/type_constraint.rb

require 'bronze/constraints/constraint'

module Bronze::Constraints
  # Constraint that matches only the given object.
  class TypeConstraint < Constraint
    # Error message for objects that match the constraint.
    KIND_OF_ERROR = 'constraints.errors.messages.kind_of'.freeze

    # Error message for objects that do not match the constraint.
    NOT_KIND_OF_ERROR = 'constraints.errors.messages.not_kind_of'.freeze

    # @param expected [Object] The expected object.
    # @param allow_nil [Boolean] True if nil is allowed in addition to the
    #   specified type, otherwise false.
    def initialize expected, allow_nil: false
      @expected  = expected
      @allow_nil = allow_nil
    end # constructor

    # @return [Object] The expected object.
    attr_reader :expected
    alias_method :type, :expected

    # @return [Boolean] True if nil is allowed in addition to the specified
    #   type, otherwise false.
    def allow_nil?
      @allow_nil
    end # method allow_nil?

    private

    def build_errors _object
      super.add(NOT_KIND_OF_ERROR, :value => @expected)
    end # method build_errors

    def build_negated_errors _object
      super.add(KIND_OF_ERROR, :value => @expected)
    end # method build_errors

    def matches_object? object
      return true if object.nil? && @allow_nil

      object.is_a?(@expected)
    end # method matches_object?
  end # class
end # module
