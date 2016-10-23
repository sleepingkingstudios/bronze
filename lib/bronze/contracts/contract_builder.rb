# lib/bronze/contracts/contract_builder.rb

require 'sleeping_king_studios/tools/toolbox/delegator'

require 'bronze/constraints/constraint_builder'
require 'bronze/contracts/contract'

module Bronze::Contracts
  # Builder object for creating and extending contract objects with a convenient
  # DSL.
  class ContractBuilder
    extend SleepingKingStudios::Tools::Toolbox::Delegator

    include Bronze::Constraints::ConstraintBuilder

    # Error class for handling empty specified constraints.
    EMPTY_CONSTRAINTS = Class.new(StandardError)

    # @param contract [Bronze::Contracts::Contract] The contract to extend. If a
    #   contract is not provided, a new contract will be created.
    def initialize contract = nil
      @contract = contract || Bronze::Contracts::Contract.new
    end # constructor

    delegate :add_constraint, :to => :contract

    # @return [Bronze::Contracts::Contract] The contract to extend.
    attr_reader :contract

    # Creates one or more constraints on the contract object or the specified
    # property with the given constraint types and parameters.
    #
    # @param property [String, Symbol] The name of the property to constrain.
    # @param constraints [Hash] The constraints to apply in hash format. The
    #   following formats are valid, and can be intermixed:
    #
    #     (constraint object) => true or false
    #
    #   Adds the given constraint. If the value is false, the constraint is
    #   negated and will be matched using the #negated_match method.
    #
    #     (constraint identifier) => true or false
    #
    #   Builds the given constraint. If the value is false, the constraint is
    #   negated.
    #
    #     (constraint identifier) => value
    #
    #   Builds the given constraint with the specified value. The constraint
    #   must take exactly 1 parameter, such as the TypeConstraint.
    #
    #     (constraint identifier) => hash
    #
    #   Builds the given constraint with the specified parameters. Common
    #   parameters include :negated => true|false and :value => value.
    def constrain property = nil, **constraints, &block
      require_constraints(constraints) unless block_given?

      build_constraints(property, constraints)

      return unless block_given?

      child   = Bronze::Contracts::Contract.new
      builder = dup
      builder.contract = child

      contract.add_constraint child, :negated => false, :on => property

      builder.instance_eval(&block)
    end # method constrain

    protected

    attr_writer :contract

    private

    def build_constraints property, constraints
      constraints.each do |constraint_key, constraint_params|
        negated, params = normalize_params(constraint_params)

        contract.add_constraint build_constraint(constraint_key, params),
          :negated => negated,
          :on      => property
      end # each
    end # method build_constraints

    def normalize_params params
      if params.is_a?(Hash)
        negated = !!params.delete(:negated)

        [negated, params]
      elsif params == true || params == false
        [!params, {}]
      else
        [false, { :value => params }]
      end # if-else
    end # method normalize_params

    def require_constraints constraints
      return unless constraints.empty?

      raise EMPTY_CONSTRAINTS,
        'must specify at least one constraint type',
        caller[1..-1]
    end # method require_constraints
  end # class
end # module