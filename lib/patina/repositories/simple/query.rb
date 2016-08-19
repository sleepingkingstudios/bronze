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
    def initialize data
      @data = data
    end # method initialize

    # (see Bronze::Repositories::Query#count)
    def count
      @data.count
    end # method count

    # (see Bronze::Repositories::Query#to_a)
    def to_a
      @data.map { |item| item.dup.freeze }.freeze
    end # method to_a
  end # class
end # module
