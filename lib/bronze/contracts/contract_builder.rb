# lib/bronze/contracts/contract_builder.rb

require 'bronze/constraints/constraint'
require 'bronze/constraints/constraint_builder'
require 'bronze/constraints/contextual_constraint'
require 'bronze/contracts'

module Bronze::Contracts
  # Domain-specific language for defining contracts.
  module ContractBuilder
    # Error class for handling empty specified constraints.
    EMPTY_CONSTRAINTS = Class.new(StandardError)

    include Bronze::Constraints::ConstraintBuilder

    # Adds the given constraint.
    #
    # @param constraint [Bronze::Constraints::Constraint] The constraint to be
    #   added.
    # @param options [Hash] Additional options for the constraint.
    def add_constraint constraint, **options
      constraints << Bronze::Constraints::ContextualConstraint.new(
        constraint,
        :if       => options[:if],
        :negated  => options[:negated],
        :property => options[:on],
        :unless   => options[:unless]
      ) # end constraint data
    end # method add_constraint

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
    def constrain property = nil, constraints = {}, &block
      if property.is_a?(Hash) && empty_constraints?(constraints)
        constraints = property
        property    = nil
      end # if

      require_constraints(constraints) unless block_given?

      build_constraints(property, constraints)

      return unless block_given?

      child = build_contract
      child.instance_exec(&block)

      add_constraint child, :negated => false, :on => property
    end # method constrain
    alias_method :validate, :constrain

    private

    def build_constraints property, constraints
      constraints = { constraints => true } unless constraints.is_a?(Hash)

      constraints.each do |constraint_or_key, constraint_params|
        options, params = normalize_params(constraint_params)

        constraint = extract_constraint(constraint_or_key, params)

        add_constraint constraint, options.merge(:on => property)
      end # each
    end # method build_constraints

    def build_contract
      if self.class < Bronze::Contracts::Contract
        self.class.new
      else
        Bronze::Contracts::Contract.new
      end # if-else
    end # method build_contract

    def constraint_name? object
      object.is_a?(String) || object.is_a?(Symbol)
    end # method constraint_name?

    def empty_constraints? object
      object.nil? || (object.respond_to?(:empty?) && object.empty?)
    end # method empty_constraints?

    def extract_constraint object, params
      constraint_type = Bronze::Constraints::Constraint

      return object if object.is_a? constraint_type

      return build_constraint(object, params) if constraint_name?(object)

      return object.contract if has_contract_method?(object)

      return object.const_get(:Contract) if has_contract_const?(object)

      raise Bronze::Constraints::ConstraintBuilder::INVALID_CONSTRAINT,
        "#{object} is not a valid constraint",
        caller
    end # method extract_constraint

    # rubocop:disable Naming/PredicateName
    def has_contract_const? object
      object.is_a?(Module) &&
        object.const_defined?(:Contract) &&
        object.const_get(:Contract).is_a?(Bronze::Constraints::Constraint)
    end # method has_contract_const?

    def has_contract_method? object
      object.respond_to?(:contract) &&
        object.contract.is_a?(Bronze::Constraints::Constraint)
    end # method has_contract_method?
    # rubocop:enable Naming/PredicateName

    def normalize_params params
      return [{ :negated => !params }, {}] if !params || params == true

      unless params.is_a?(Hash)
        return [{ :negated => false }, { :value => params }]
      end # unless

      options = {
        :if      => params.delete(:if),
        :negated => !!params.delete(:negated),
        :unless  => params.delete(:unless)
      } # end hash

      [options, params]
    end # method normalize_params

    def require_constraints constraints
      return unless constraints.nil? ||
                    (constraints.is_a?(Hash) && constraints.empty?)

      raise EMPTY_CONSTRAINTS,
        'must specify at least one constraint',
        caller(1..-1)
    end # method require_constraints
  end # module
end # module

require 'bronze/contracts/contract'
