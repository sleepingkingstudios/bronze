# lib/patina/operations/entities/validate_one_operation.rb

require 'bronze/constraints/constraint'
require 'bronze/contracts/contract'
require 'bronze/operations/operation'

require 'patina/operations/entities'
require 'patina/operations/entities/error_messages'
require 'patina/operations/entities/resource_operation'

module Patina::Operations::Entities
  # Validates the given resource.
  class ValidateOneOperation < Bronze::Operations::Operation
    include Patina::Operations::Entities::ErrorMessages
    include Patina::Operations::Entities::ResourceOperation

    def initialize; end

    # @return [Bronze::Entities::Entity] The validated resource.
    attr_reader :resource

    private

    # rubocop:disable Style/PredicateName
    def has_contract_const?
      resource_class.const_defined?(:Contract) &&
        resource_class.const_get(:Contract) < Bronze::Contracts::Contract
    end # method has_contract_const?

    def has_contract_method?
      resource_class.respond_to?(:contract) &&
        resource_class.contract.is_a?(Bronze::Constraints::Constraint)
    end # method has_contract_method?
    # rubocop:enable Style/PredicateName

    def merge_resource_errors errors
      @errors = Bronze::Errors::Errors.new

      errors.each do |error|
        @errors.
          dig(resource_name, *error.nesting).
          add(error.type, error.params)
      end # each
    end # method merge_resource_errors

    def process resource, contract = nil
      @resource = resource

      contract ||= resource_contract

      return unless contract

      result, errors = contract.match resource

      return if result

      @failure_message = INVALID_RESOURCE

      merge_resource_errors errors
    end # method process

    def resource_class
      @resource ? @resource.class : ''
    end # method resource_class

    def resource_contract
      @resource_contract ||=
        if has_contract_const?
          resource_class::Contract.new
        end # if
    end # method resource_contract
  end # class
end # module
