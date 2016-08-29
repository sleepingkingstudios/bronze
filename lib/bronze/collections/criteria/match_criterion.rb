# lib/bronze/collections/criteria/match_criterion.rb

require 'bronze/collections/criteria/criterion'

module Bronze::Collections::Criteria
  # Abstract class for a match criterion, which restricts the data returned from
  # the datastore to data matching the given selector.
  class MatchCriterion < Criterion
    # @param selector [Hash] The selector against which data is compared.
    def initialize selector
      @selector = selector
    end # method initialize

    # @return [Hash] The selector against which data is compared.
    attr_reader :selector
  end # class
end # module
