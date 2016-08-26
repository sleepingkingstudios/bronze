# spec/bronze/collections/reference/query.rb

require 'bronze/collections/query'

module Spec::Reference
  # A reference implementation of Bronze::Collections::Query that uses a Ruby
  # Array as its data source.
  class Query < Bronze::Collections::Query
    # @param data [Array[Hash]] The source data for the query.
    # @param transform [Bronze::Transforms::Transform] The transform
    #   object to map raw data into entities.
    def initialize data, transform
      @data      = data
      @transform = transform
    end # constructor

    # (see Query#count)
    def count
      @data.count
    end # method count

    private

    def find_each
      @data.map { |hsh| yield hsh }
    end # method find_each
  end # class
end # module
