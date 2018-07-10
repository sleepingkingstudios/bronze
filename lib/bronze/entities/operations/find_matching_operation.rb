require 'bronze/entities/operations/persistence_operation'

require 'cuprum/operation'

module Bronze::Entities::Operations
  # Operation for retrieving all entities from a repository matching a given
  # selector.
  class FindMatchingOperation < Cuprum::Operation
    include Bronze::Entities::Operations::PersistenceOperation

    private

    # Queries the repository for all entities matching the given selector.
    #
    # @param matching [Hash] The selector to match.
    #
    # @return [Array<Bronze::Entities::Entity>] The entities returned by the
    #   query.
    #
    # @see Bronze::Collections::Query#matching.
    def process matching: {}
      query = collection.query

      query = query.matching(matching) if matching.is_a?(Hash)

      query.to_a.map { |entity| persist_entity(entity) }
    end
  end
end
