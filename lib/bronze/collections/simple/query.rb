# frozen_string_literal: true

require 'bronze/collections/query'
require 'bronze/collections/simple'

module Bronze::Collections::Simple
  # Query class that filters in-memory data in an Array of Hashes format.
  class Query < Bronze::Collections::Query
    # @param [Array<Hash>] data The data to query against.
    def initialize(data)
      @data = data
    end

    # (see Bronze::Collections::Query#count)
    def count
      each.reduce(0) { |count, _| count + 1 }
    end

    # (see Bronze::Collections::Query#each)
    def each
      return enum_for(:matching_data) unless block_given?

      matching_data { |item| yield item }
    end

    private

    attr_reader :data

    def matching_data
      data.each do |item|
        yield item
      end
    end
  end
end
