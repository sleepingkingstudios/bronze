require 'bronze/operations/base_operation'
require 'bronze/operations/persistence_operation'

module Bronze::Operations
  # Operation for retrieving entities from a repository from a list of entity
  # primary keys.
  class FindManyOperation < Bronze::Operations::BaseOperation
    include Bronze::Operations::PersistenceOperation

    private

    def add_errors expected_keys, actual_keys
      missing_keys = expected_keys - actual_keys

      missing_keys.each do |primary_key|
        result.errors[plural_entity_name].add(
          Bronze::Collections::Collection::Errors.record_not_found,
          :id => primary_key
        )
      end
    end

    # Queries the repository for the entities with the given primary keys. The
    # operation succeeds if an entity is found for each primary key, or fails
    # if an entity is not found for one or more primary keys.
    #
    # @param primary_keys [Array<Object>] The primary keys to search for in the
    #   repository.
    #
    # @return [Array<Bronze::Entities::Entity>] The entities returned by the
    #   query.
    #
    # @see Bronze::Collections::Query#find.
    def process *primary_keys
      expected_keys = Array(primary_keys)

      if expected_keys.size == 1 && expected_keys.first.is_a?(Array)
        expected_keys = expected_keys.first
      end

      found_entities =
        collection.matching(:id => { :__in => expected_keys }).to_a

      add_errors(expected_keys, found_entities.map(&:id))

      found_entities.map { |entity| persist_entity(entity) }
    end
  end
end
