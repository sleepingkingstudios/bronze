# lib/patina/operations/entities/insert_one_operation.rb

require 'bronze/operations/operation'

require 'patina/operations/entities'
require 'patina/operations/entities/error_messages'
require 'patina/operations/entities/persistence_operation'

module Patina::Operations::Entities
  # Inserts the entity into the repository as a new record.
  class InsertOneOperation < Bronze::Operations::Operation
    include Patina::Operations::Entities::ErrorMessages
    include Patina::Operations::Entities::PersistenceOperation

    # @return [Bronze::Entities::Entity] The inserted resource.
    attr_reader :resource

    private

    def process resource
      @resource = resource

      result, _ = collection.insert(resource)

      return if result

      @failure_message = RECORD_ALREADY_EXISTS

      error_definitions = Bronze::Collections::Collection::Errors

      @errors[resource_name].add(
        error_definitions::RECORD_ALREADY_EXISTS,
        :id => resource.id
      ) # end add
    end # method process
  end # class
end # module
