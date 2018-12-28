# spec/bronze/collections/reference/query.rb

require 'bronze/collections/query'
require 'bronze/collections/reference'
require 'bronze/utilities/hash_filter'

module Bronze::Collections::Reference
  # Reference implementation of Bronze::Collections::Query.
  class Query < ::Bronze::Collections::Query
    module Criteria
      # Restricts the number of results returned from the datastore.
      class LimitCriterion < Bronze::Collections::Criteria::LimitCriterion
        # (see Bronze::Collections::Criteria::Criterion#call)
        def call data
          data[0...count]
        end # method call
      end # class

      # Filters the given data using the selector.
      class MatchCriterion < Bronze::Collections::Criteria::MatchCriterion
        # (see Bronze::Collections::Criteria::Criterion#call)
        def call data
          filter = Bronze::Utilities::HashFilter.new(selector)

          data.select { |hsh| filter.matches?(hsh) }
        end # method call
      end # class
    end # module

    # @param data [Array[Hash]] The source data for the query.
    # @param transform [Bronze::Transform] The transform object to map raw data
    #   into entities.
    def initialize data, transform
      @data      = data
      @transform = transform
    end # method initialize

    # (see Bronze::Collections::Query#count)
    def count
      filtered = apply_criteria(@data)
      filtered.count
    end # method count

    private

    def criteria_namespace
      Criteria
    end # method criteria_namespace

    def find_each
      apply_criteria(@data).each { |hsh| yield hsh }
    end # method find_each
  end # class
end # module
