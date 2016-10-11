# spec/bronze/constraints/failure_constraint.rb

require 'bronze/constraints/constraint'

module Spec
  # An implementation of Bronze::Constraints::Constraint that does not match any
  # objects.
  class FailureConstraint < Bronze::Constraints::Constraint
    # Error message for objects that do not match the constraint.
    INVALID_ERROR = 'constraints.errors.invalid_object'.freeze

    # @param error_type [Symbol] The type of error to return. If no error type
    #   is specified, will default to INVALID_ERROR.
    # @param error_params [Array] Optional params to return with the error.
    def initialize error_type = INVALID_ERROR, *error_params
      @error_type   = error_type
      @error_params = error_params
    end # constructor

    private

    def build_errors _object
      super.add(@error_type, *@error_params)
    end # method build_errors

    def matches_object? _object
      false
    end # method matches_object?
  end # class
end # module
