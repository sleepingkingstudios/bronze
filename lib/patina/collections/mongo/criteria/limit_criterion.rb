# lib/patina/collections/mongo/criteria/limit_criterion.rb

require 'bronze/collections/criteria/limit_criterion'

require 'patina/collections/mongo/query'

module Patina::Collections::Mongo
  # Namespace for query criteria, which encode restrictions or expectations on
  # the data returned from a datastore.
  module Criteria
    # Filters the given data using the selector.
    class LimitCriterion < Bronze::Collections::Criteria::LimitCriterion
      # (see Bronze::Collections::Criteria::Criterion#call)
      def call args
        filter, options = *args

        limit = [count, options[:limit]].compact.min

        [filter, options.merge(:limit => limit)]
      end # method call
    end # class
  end # module
end # module
