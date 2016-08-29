# lib/patina/collections/simple/criteria/match_criterion.rb

require 'bronze/collections/criteria/match_criterion'
require 'patina/collections/simple/query'

module Patina::Collections::Simple
  module Criteria
    # Filters the given data using the selector.
    class MatchCriterion < Bronze::Collections::Criteria::MatchCriterion
      def call data
        data.select { |hsh| hsh >= selector }
      end # method call
    end # class
  end # module
end # module
