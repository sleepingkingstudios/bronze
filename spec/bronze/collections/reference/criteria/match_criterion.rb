# spec/bronze/collections/reference/criteria/match_criterion.rb

require 'bronze/collections/criteria/match_criterion'
require 'bronze/collections/reference/query'

module Spec::Reference
  module Criteria
    # Namespace for query criteria, which encode restrictions or expectations on
    # the data returned from a datastore.
    class MatchCriterion < Bronze::Collections::Criteria::MatchCriterion
      # (see Bronze::Collections::Criteria::Criterion#call)
      def call data
        data.select { |hsh| hsh >= selector }
      end # method call
    end # class
  end # module
end # module
