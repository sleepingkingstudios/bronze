# lib/patina/collections/simple/collection_builder.rb

require 'bronze/collections/collection_builder'
require 'patina/collections/simple/collection'

module Patina::Collections::Simple
  # Builder object for creating instances of
  # Patina::Collections::SimpleCollection.
  class CollectionBuilder < ::Bronze::Collections::CollectionBuilder
    # @param (see Bronze::Collections::CollectionBuilder#initialize)
    # @param @data [Hash] The repository's data hash.
    def initialize collection_type, data
      super(collection_type)

      @data = data
    end # constructor

    # (see Bronze::Collections::CollectionBuilder#collection_class)
    def collection_class
      Patina::Collections::Simple::Collection
    end # method collection_class

    private

    attr_reader :data

    def build_collection
      collection_class.new(data[collection_name.intern])
    end # method
  end # class
end # module
