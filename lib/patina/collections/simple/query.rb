# lib/patina/collections/simple/query.rb

require 'bronze/collections/query'
require 'patina/collections/simple'

module Patina::Collections::Simple
  # Implementation of Bronze::Collections::Query for an Array-of-Hashes
  # in-memory data store.
  #
  # @see Simple::Collection
  class Query < Bronze::Collections::Query
    # @param data [Array[Hash]] The source data for the query.
    # @param transform [Bronze::Transforms::Transform] The transform
    #   object to map raw data into entities.
    def initialize data, transform
      @data      = data
      @transform = transform
    end # method initialize

    # (see Bronze::Collections::Query#count)
    def count
      @data.count
    end # method count

    private

    def find_each
      @data.map { |hsh| yield hsh }
    end # method find_each
  end # class
end # module