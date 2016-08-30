# lib/bronze/collections/criteria/limit_criterion.rb

require 'bronze/collections/criteria/criterion'

module Bronze::Collections::Criteria
  # Abstract class for a limit criterion, which restricts the number of results
  # returned from the datastore.
  class LimitCriterion < Criterion
    # @param count [Integer] The maximum number of results to return.
    def initialize count
      @count = count
      @type  = :limit
    end # method initialize

    # @return [Integer] The maximum number of results to return.
    attr_reader :count
  end # class
end # module
