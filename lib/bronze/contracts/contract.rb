# lib/bronze/contracts/contract.rb

require 'bronze/constraints/constraint'

module Bronze::Contracts
  # An aggregation of constraints with support for additional context, such as
  # apply constraints to the object's properties. Provides a DSL for quickly
  # defining a contract using the predefined constraint classes.
  class Contract < Bronze::Constraints::Constraint
    # @api private
    class ConstraintData
      def initialize constraint, if_proc:, negated:, nesting:, unless_proc:
        @constraint  = constraint
        @if_proc     = if_proc
        @negated     = negated
        @nesting     = nesting
        @unless_proc = unless_proc
      end # method initialize

      attr_reader :constraint, :if_proc, :nesting, :unless_proc

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
    def add_constraint constraint, negated: false, on: [], **kwargs
      @constraints << ConstraintData.new(
        constraint,
        :if_proc     => kwargs[:if],
        :negated     => negated,
        :nesting     => Array(on),
        :unless_proc => kwargs[:unless]
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

    def apply_with_arity proc, object, property = nil
      if proc.arity >= 2
        object.instance_exec(object, property, &proc)
      elsif proc.arity == 1
        object.instance_exec(object, &proc)
      else
        object.instance_exec(&proc)
      end # if-else
    end # method apply_with_arity

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
      return true if skip_constraint?(object, constraint_data)

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

    def skip_constraint? object, data
      property = Array(data.nesting).first

      if data.if_proc
        return true unless apply_with_arity(data.if_proc, object, property)
      elsif data.unless_proc
        return true if apply_with_arity(data.unless_proc, object, property)
      end # if-elsif

      false
    end # method skip_constraint?

    def update_errors constraint_data, errors
      nesting = resolve_nesting(@errors, constraint_data.nesting)

      nesting.update(errors)
    end # method update_errors
  end # class
end # module
