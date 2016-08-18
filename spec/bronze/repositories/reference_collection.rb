# spec/bronze/repositories/reference_collection.rb

require 'bronze/repositories/collection'
require 'bronze/repositories/reference_query'

module Spec
  # A reference implementation of Bronze::Repositories::Collection that uses a
  # Ruby Array as its data source.
  class ReferenceCollection < Bronze::Repositories::Collection
    # @param name [Symbol] The name of the collection.
    # @param data [Array[Hash]] The source data for the collection.
    def initialize name, data
      super(name)

      @data = data
    end # constructor

    private

    def base_query
      ::Spec::ReferenceQuery.new(@data)
    end # method base_query
  end # class
end # class
