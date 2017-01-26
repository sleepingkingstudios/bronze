# lib/patina/collections/simple/criteria/limit_criterion.rb

require 'bronze/collections/criteria/limit_criterion'

require 'patina/collections/simple/query'

module Patina::Collections::Simple
  # Namespace for query criteria, which encode restrictions or expectations on
  # the data returned from a datastore.
  module Criteria
    # Restricts the number of results returned from the datastore.
    class LimitCriterion < Bronze::Collections::Criteria::LimitCriterion
      # (see Bronze::Collections::Criteria::Criterion#call)
      def call data
        data[0...count]
      end # method call
    end # class
  end # module
end # module
