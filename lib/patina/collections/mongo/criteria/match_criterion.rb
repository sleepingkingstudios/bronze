# lib/patina/collections/mongo/criteria/match_criterion.rb

require 'bronze/collections/criteria/match_criterion'

require 'patina/collections/mongo/query'

module Patina::Collections::Mongo
  # Namespace for query criteria, which encode restrictions or expectations on
  # the data returned from a datastore.
  module Criteria
    # Filters the given data using the selector.
    class MatchCriterion < Bronze::Collections::Criteria::MatchCriterion
      # (see Bronze::Collections::Criteria::Criterion#call)
      def call args
        filter, options = *args

        [filter.merge(selector), options]
      end # method call
    end # class
  end # module
end # module
