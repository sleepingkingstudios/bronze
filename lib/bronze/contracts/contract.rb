# lib/bronze/contracts/contract.rb

require 'bronze/constraints/constraint'
require 'bronze/constraints/constraint_builder'
require 'bronze/constraints/contextual_constraint'

module Bronze::Contracts
  # An aggregation of constraints with support for additional context, such as
  # apply constraints to the object's properties. Provides a DSL for quickly
  # defining a contract using the predefined constraint classes.
  class Contract < Bronze::Constraints::Constraint
    # Error class for handling empty specified constraints.
    EMPTY_CONSTRAINTS = Class.new(StandardError)

    # @api private
    module BuilderMethods
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
        if property.is_a?(Hash) && empty?(constraints)
          constraints = property
          property    = nil
        end # if

        require_constraints(constraints) unless block_given?

        build_constraints(property, constraints)

        return unless block_given?

        child = is_a?(Class) ? new : self.class.new
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

      def constraint_name? object
        object.is_a?(String) || object.is_a?(Symbol)
      end # method constraint_name?

      def empty? object
        object.nil? || (object.respond_to?(:empty?) && object.empty?)
      end # method empty?

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

      # rubocop:disable Style/PredicateName
      def has_contract_const? object
        object.is_a?(Module) &&
          object.const_defined?(:Contract) &&
          object.const_get(:Contract).is_a?(Bronze::Constraints::Constraint)
      end # method has_contract_const?

      def has_contract_method? object
        object.respond_to?(:contract) &&
          object.contract.is_a?(Bronze::Constraints::Constraint)
      end # method has_contract_method?
      # rubocop:enable Style/PredicateName

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
          caller[1..-1]
      end # method require_constraints
    end # module
    private_constant :BuilderMethods

    class << self
      include BuilderMethods

      # @return [Array] The constraints defined on the contract class.
      def constraints
        @constraints ||= []
      end # method constraints
    end # class << self

    include BuilderMethods

    def initialize
      @constraints = []
    end # constructor

    # @return [Array] The constraints defined on the contract.
    attr_reader :constraints

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

    def each_constraint &block
      @constraints.each(&block)

      contract_class = self.class

      while contract_class < Bronze::Contracts::Contract
        contract_class.constraints.each(&block)

        contract_class = contract_class.superclass
      end # while
    end # method each_constraint

    def matches_object? object
      each_constraint do |constraint_data|
        _, errors = constraint_data.match(object)

        update_errors(constraint_data, errors) unless errors.empty?
      end # each

      @errors.empty?
    end # method matches_object?

    def negated_matches_object? object
      each_constraint do |constraint_data|
        _, errors = constraint_data.negated_match(object)

        update_errors(constraint_data, errors) unless errors.empty?
      end # each

      @errors.empty?
    end # method negated_matches_object?

    def update_errors constraint_data, errors
      property = constraint_data.property
      nesting  = property ? @errors[property] : @errors

      nesting.update(errors)
    end # method update_errors
  end # class
end # module
