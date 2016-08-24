# spec/bronze/repositories/reference_query.rb

require 'bronze/repositories/query'

module Spec
  # A reference implementation of Bronze::Repositories::Query that uses a Ruby
  # Array as its data source.
  class ReferenceQuery < Bronze::Repositories::Query
    # @param data [Array[Hash]] The source data for the query.
    # @param transform [Bronze::Entities::Transforms::Transform] The transform
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
