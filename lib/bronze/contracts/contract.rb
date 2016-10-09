# lib/bronze/contracts/contract.rb

require 'bronze/constraints/constraint'

module Bronze::Contracts
  # An aggregation of constraints with support for additional context, such as
  # apply constraints to the object's properties. Provides a DSL for quickly
  # defining a contract using the predefined constraint classes.
  class Contract < Bronze::Constraints::Constraint
    # @api private
    class ConstraintData
      def initialize constraint, nesting:
        @constraint = constraint
        @nesting    = nesting
      end # method initialize

      attr_reader :constraint, :nesting
    end # class
    private_constant :ConstraintData

    def initialize
      @constraints = []
    end # constructor

    # @return [Array] The constraints defined on the contract.
    attr_reader :constraints

    # Adds the given constraint to the contract.
    #
    # @param constraint [Bronze::Constraints::Constraint] THe constraint to be
    #   added.
    def add_constraint constraint, on: []
      @constraints << ConstraintData.new(constraint, :nesting => Array(on))
    end # method add_constraint

    def match object
      @errors = Bronze::Errors::Errors.new

      super
    end # method match

    private

    def build_errors _object
      @errors
    end # method build_errors

    def matches_object? object
      @constraints.each do |constraint_data|
        value      = object
        constraint = constraint_data.constraint

        result, errors = constraint.match(value)

        update_errors(constraint_data, errors) unless errors.empty?

        result
      end # each

      @errors.empty?
    end # method matches_object?

    def resolve_nesting parent, fragments
      fragments.reduce(parent) { |memo, fragment| memo[fragment] }
    end # method resolve_nesting

    def update_errors constraint_data, errors
      nesting = resolve_nesting(@errors, constraint_data.nesting)

      nesting.update(errors)
    end # method update_errors
  end # class
end # module
