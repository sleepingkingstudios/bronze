# lib/patina/repositories/simple/query.rb

require 'bronze/repositories/query'
require 'patina/repositories/simple'

module Patina::Repositories::Simple
  # Implementation of Bronze::Repositories::Query for an Array-of-Hashes
  # in-memory data store.
  #
  # @see Simple::Collection
  class Query < Bronze::Repositories::Query
    # @param data [Array[Hash]] The source data for the query.
    # @param transform [Bronze::Entities::Transforms::Transform] The transform
    #   object to map raw data into entities.
    def initialize data, transform
      @data      = data
      @transform = transform
    end # method initialize

    # (see Bronze::Repositories::Query#count)
    def count
      @data.count
    end # method count

    private

    def find_each
      @data.map { |hsh| yield hsh }
    end # method find_each
  end # class
end # module
