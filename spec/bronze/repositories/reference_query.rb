# spec/bronze/repositories/reference_query.rb

require 'bronze/repositories/query'

module Spec
  # A reference implementation of Bronze::Repositories::Query that uses a Ruby
  # Array as its data source.
  class ReferenceQuery < Bronze::Repositories::Query
    # @param data [Array[Hash]] The source data for the query.
    def initialize data
      @data = data
    end # constructor

    # (see Query#count)
    def count
      @data.count
    end # method count

    # (see Query#to_a)
    def to_a
      @data
    end # method to_a
  end # class
end # module
