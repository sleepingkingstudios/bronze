# lib/patina/operations/entities/find_many_operation.rb

require 'bronze/operations/operation'

require 'patina/operations/entities'
require 'patina/operations/entities/error_messages'
require 'patina/operations/entities/persistence_operation'

module Patina::Operations::Entities
  # Queries the repository for records with the given primary keys.
  class FindManyOperation < Bronze::Operations::Operation
    include Patina::Operations::Entities::ErrorMessages
    include Patina::Operations::Entities::PersistenceOperation

    # @return [Array<Bronze::Entities::Entity>] The found resources, if any.
    attr_reader :resources

    private

    def append_errors missing_primary_keys
      error_definitions = Bronze::Collections::Collection::Errors

      missing_primary_keys.each do |primary_key|
        @errors[plural_resource_name][primary_key].add(
          error_definitions::RECORD_NOT_FOUND,
          :id => primary_key
        ) # end errors
      end # each
    end # method append_errors

    def process primary_keys
      primary_keys = Array(primary_keys).uniq

      query = collection.matching(:id => { :__in => primary_keys })

      @resources = query.to_a

      return if primary_keys.count == @resources.count

      @failure_message = RECORD_NOT_FOUND

      missing_primary_keys = primary_keys - @resources.map(&:id)

      append_errors(missing_primary_keys)
    end # method process
  end # class
end # module
