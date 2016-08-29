# spec/bronze/collections/reference/criteria/match_criterion.rb

require 'bronze/collections/criteria/match_criterion'
require 'bronze/collections/reference/query'

module Spec::Reference
  module Criteria
    class MatchCriterion < Bronze::Collections::Criteria::MatchCriterion
      def call data
        data.select { |hsh| hsh >= selector }
      end # method call
    end # class
  end # module
end # module
