# lib/patina/operations/entities/find_one_operation.rb

require 'bronze/operations/operation'

require 'patina/operations/entities'
require 'patina/operations/entities/error_messages'
require 'patina/operations/entities/persistence_operation'

module Patina::Operations::Entities
  # Queries the repository for the record with the given class and primary key.
  class FindOneOperation < Bronze::Operations::Operation
    include Patina::Operations::Entities::ErrorMessages
    include Patina::Operations::Entities::PersistenceOperation

    # @return [Bronze::Entities::Entity] The found resource, if any.
    attr_reader :resource

    private

    def process primary_key
      @resource = collection.find(primary_key) unless primary_key.nil?

      return if @resource

      @failure_message = RECORD_NOT_FOUND

      error_definitions = Bronze::Collections::Collection::Errors

      @errors[resource_name].add(
        error_definitions::RECORD_NOT_FOUND,
        :id => primary_key
      ) # end errors
    end # method process
  end # class
end # module
