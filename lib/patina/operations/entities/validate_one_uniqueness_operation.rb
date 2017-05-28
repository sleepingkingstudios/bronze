# lib/patina/operations/entities/validate_one_uniqueness_operation.rb

require 'bronze/operations/operation'

require 'patina/operations/entities'
require 'patina/operations/entities/error_messages'
require 'patina/operations/entities/persistence_operation'

module Patina::Operations::Entities
  # Validates the uniqueness of the entity in the given collection.
  class ValidateOneUniquenessOperation < Bronze::Operations::Operation
    include Patina::Operations::Entities::ErrorMessages
    include Patina::Operations::Entities::PersistenceOperation

    # @return [Bronze::Entities::Entity] The checked resource.
    attr_reader :resource

    private

    def process resource
      @resource = resource

      return unless resource.respond_to?(:match_uniqueness)

      result, errors = resource.match_uniqueness(collection)

      return if result

      @errors[resource_name].update(errors)

      @failure_message = RECORD_NOT_UNIQUE
    end # method process
  end # module
end # module
