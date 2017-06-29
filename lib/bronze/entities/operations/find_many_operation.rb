# lib/bronze/entities/operations/find_many_operation.rb

require 'bronze/entities/operations/persistence_operation'

module Bronze::Entities::Operations
  # Operation for retrieving entities from a repository from a list of entity
  # primary keys.
  class FindManyOperation < Bronze::Entities::Operations::PersistenceOperation
    def process *primary_keys
      expected_keys = Array(primary_keys)

      if expected_keys.size == 1 && expected_keys.first.is_a?(Array)
        expected_keys = expected_keys.first
      end # if

      found_entities =
        collection.matching(:id => { :__in => expected_keys }).to_a

      add_errors(expected_keys, found_entities.map(&:id))

      found_entities
    end # method process

    private

    def add_errors expected_keys, actual_keys
      missing_keys = expected_keys - actual_keys

      missing_keys.each do |primary_key|
        @errors[plural_entity_name].add(
          Bronze::Collections::Collection::Errors.record_not_found,
          :id => primary_key
        ) # end error
      end # each
    end # method add_errors
  end # class
end # module
