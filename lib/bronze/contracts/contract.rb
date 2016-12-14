# lib/bronze/contracts/contract.rb

require 'sleeping_king_studios/tools/toolbox/delegator'

require 'bronze/contracts/contract_builder'

module Bronze::Contracts
  # An aggregation of constraints with support for additional context, such as
  # apply constraints to the object's properties. Provides a DSL for quickly
  # defining a contract using the predefined constraint classes.
  class Contract < Bronze::Constraints::Constraint
    class << self
      extend SleepingKingStudios::Tools::Toolbox::Delegator

      delegate :add_constraint,
        :constrain,
        :constraints,
        :validate,
        :to => :prototype

      private

      def prototype
        @prototype ||= new
      end # method prototype
    end # class << self

    include Bronze::Contracts::ContractBuilder

    def initialize
      @constraints = []
    end # constructor

    # @return [Array] The constraints defined on the contract.
    attr_reader :constraints

    # @return [Boolean] True if the contract does not have any constraints,
    #   otherwise false.
    def empty?
      each_constraint { |_| return false }

      true
    end # method empty?

    private

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
        property = constraint_data.property
        nesting  = property ? errors[property] : errors

        constraint_data.match(object, nesting)
      end # each

      errors.empty?
    end # method matches_object?

    def negated_matches_object? object
      each_constraint do |constraint_data|
        property = constraint_data.property
        nesting  = property ? errors[property] : errors

        constraint_data.negated_match(object, nesting)
      end # each

      errors.empty?
    end # method negated_matches_object?

    def update_errors constraint_data, errors
      property = constraint_data.property
      nesting  = property ? @errors[property] : @errors

      nesting.update(errors)
    end # method update_errors
  end # class
end # module
