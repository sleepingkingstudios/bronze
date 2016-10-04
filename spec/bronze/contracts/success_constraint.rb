# spec/bronze/contracts/success_constraint.rb

require 'bronze/contracts/constraint'

module Spec
  # An implementation of Bronze::Contracts::Constraint that matches all objects.
  class SuccessConstraint < Bronze::Contracts::Constraint
    private

    def matches_object? _object
      true
    end # method matches_object?
  end # class
end # module
