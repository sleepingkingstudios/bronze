# lib/bronze/entities/operations/find_matching_operation.rb

require 'bronze/entities/operations/persistence_operation'
require 'bronze/operations/operation'

module Bronze::Entities::Operations
  # Operation for retrieving all entities from a repository matching a given
  # selector.
  class FindMatchingOperation < Bronze::Operations::Operation
    include Bronze::Entities::Operations::PersistenceOperation

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

      query.to_a
    end # method process
  end # class
end # module
