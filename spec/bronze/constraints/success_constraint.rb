# spec/bronze/constraints/success_constraint.rb

require 'bronze/constraints/constraint'

module Spec
  # An implementation of Bronze::Constraints::Constraint that matches all
  # objects.
  class SuccessConstraint < Bronze::Constraints::Constraint
    private

    def matches_object? _object
      true
    end # method matches_object?
  end # class
end # module
