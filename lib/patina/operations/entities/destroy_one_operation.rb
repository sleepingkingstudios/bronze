# lib/patina/operations/entities/destroy_one_operation.rb

require 'bronze/operations/operation'

require 'patina/operations/entities'
require 'patina/operations/entities/error_messages'
require 'patina/operations/entities/persistence_operation'

module Patina::Operations::Entities
  # Removes from the repository the record corresponding to the given entity.
  class DestroyOneOperation < Bronze::Operations::Operation
    include Patina::Operations::Entities::ErrorMessages
    include Patina::Operations::Entities::PersistenceOperation

    # @return [Bronze::Entities::Entity] The destroyed resource.
    attr_reader :resource

    private

    def process resource
      @resource = resource

      result, _ = collection.delete resource.id

      return if result

      error_definitions = Bronze::Collections::Collection::Errors

      @errors[resource_name].add(
        error_definitions::RECORD_NOT_FOUND,
        :id => resource.id
      ) # end add
    end # method process
  end # class
end # module
