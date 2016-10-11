# lib/bronze/contracts/contract.rb

require 'bronze/constraints/constraint'

module Bronze::Contracts
  # An aggregation of constraints with support for additional context, such as
  # apply constraints to the object's properties. Provides a DSL for quickly
  # defining a contract using the predefined constraint classes.
  class Contract < Bronze::Constraints::Constraint
    # @api private
    class ConstraintData
      def initialize constraint, negated:, nesting:
        @constraint = constraint
        @negated    = negated
        @nesting    = nesting
      end # method initialize

      attr_reader :constraint, :nesting

      def negated?
        !!@negated
      end # method negated?
    end # class
    private_constant :ConstraintData

    def initialize
      @constraints = []
    end # constructor

    # @return [Array] The constraints defined on the contract.
    attr_reader :constraints

    # Adds the given constraint to the contract.
    #
    # @param constraint [Bronze::Constraints::Constraint] The constraint to be
    #   added.
    def add_constraint constraint, negated: false, on: []
      @constraints << ConstraintData.new(
        constraint,
        :negated => negated,
        :nesting => Array(on)
      ) # end constraint data
    end # method add_constraint

    def match object
      @errors = Bronze::Errors::Errors.new

      super
    end # method match

    def negated_match object
      @errors = Bronze::Errors::Errors.new

      super
    end # method match

    private

    def build_errors _object
      @errors
    end # method build_errors

    def build_negated_errors _object
      @errors
    end # method build_errors

    def dig object, nesting
      nesting.reduce(object) do |memo, fragment|
        if memo.respond_to?(fragment)
          memo.send(fragment)
        elsif memo.respond_to?(:[])
          memo[fragment]
        end # if-elsif
      end # reduce
    end # method dig

    def match_constraint object, constraint_data, negated:
      value      = dig(object, constraint_data.nesting)
      constraint = constraint_data.constraint

      match_method   = negated ? :negated_match : :match
      result, errors = constraint.send(match_method, value)

      update_errors(constraint_data, errors) unless errors.empty?

      result
    end # method match_constraint

    def matches_object? object
      @constraints.each do |constraint_data|
        match_constraint(
          object,
          constraint_data,
          :negated => constraint_data.negated?
        ) # end match_constraint
      end # each

      @errors.empty?
    end # method matches_object?

    def negated_matches_object? object
      @constraints.each do |constraint_data|
        match_constraint(
          object,
          constraint_data,
          :negated => !constraint_data.negated?
        ) # end match_constraint
      end # each

      @errors.empty?
    end # method negated_matches_object?

    def resolve_nesting parent, fragments
      fragments.reduce(parent) { |memo, fragment| memo[fragment] }
    end # method resolve_nesting

    def update_errors constraint_data, errors
      nesting = resolve_nesting(@errors, constraint_data.nesting)

      nesting.update(errors)
    end # method update_errors
  end # class
end # module
