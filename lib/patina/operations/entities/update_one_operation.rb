# lib/patina/operations/entities/update_one_operation.rb

require 'bronze/operations/operation'

require 'patina/operations/entities'
require 'patina/operations/entities/error_messages'
require 'patina/operations/entities/persistence_operation'

module Patina::Operations::Entities
  # Updates the record corresponding to the given entity.
  class UpdateOneOperation < Bronze::Operations::Operation
    include Patina::Operations::Entities::ErrorMessages
    include Patina::Operations::Entities::PersistenceOperation

    # @return [Bronze::Entities::Entity] The updated resource.
    attr_reader :resource

    private

    def process resource
      @resource = resource

      result, _ = collection.update(resource.id, resource)

      return if result

      error_definitions = Bronze::Collections::Collection::Errors

      @errors[resource_name].add(
        error_definitions::RECORD_NOT_FOUND,
        :id => resource.id
      ) # end add
    end # method process
  end # class
end # module
