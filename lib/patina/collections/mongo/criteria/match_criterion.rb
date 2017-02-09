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

        hsh = mongoize_hash(selector)

        [filter.merge(hsh), options]
      end # method call

      private

      def mongoize_hash hsh
        hsh.each.with_object({}) do |(key, value), other|
          other_key = key.to_s.start_with?('__') ? "$#{key.to_s[2..-1]}" : key

          other_value = value.is_a?(Hash) ? mongoize_hash(value) : value

          other[other_key] = other_value
        end # each
      end # method mongoize_hash
    end # class
  end # module
end # module
