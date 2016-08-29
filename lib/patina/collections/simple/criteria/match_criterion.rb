# lib/patina/collections/simple/criteria/match_criterion.rb

require 'bronze/collections/criteria/match_criterion'
require 'patina/collections/simple/query'

module Patina::Collections::Simple
  # Namespace for query criteria, which encode restrictions or expectations on
  # the data returned from a datastore.
  module Criteria
    # Filters the given data using the selector.
    class MatchCriterion < Bronze::Collections::Criteria::MatchCriterion
      # (see Bronze::Collections::Criteria::Criterion#call)
      def call data
        data.select { |hsh| hsh >= selector }
      end # method call
    end # class
  end # module
end # module
