# lib/patina/operations/entities/find_matching_operation.rb

require 'bronze/operations/operation'

require 'patina/operations/entities'
require 'patina/operations/entities/persistence_operation'

module Patina::Operations::Entities
  # Queries the repository for records matching the given params.
  class FindMatchingOperation < Bronze::Operations::Operation
    include Patina::Operations::Entities::PersistenceOperation

    # @return [Array<Bronze::Entities::Entity>] The found resources, if any.
    attr_reader :resources

    private

    def extract_option options, name
      options.fetch(name, options[name.to_s])
    end # method extract_option

    def process options = {}
      query = collection.query

      matching = extract_option(options, :matching)

      query = query.matching(matching) if matching.is_a?(Hash)

      @resources = query.to_a
    end # method process
  end # class
end # module
