# spec/bronze/collections/reference/collection_builder.rb

require 'bronze/collections/collection_builder'
require 'bronze/collections/reference'
require 'bronze/collections/reference/collection'

module Bronze::Collections::Reference
  # Reference implementation of Bronze::Collections::CollectionBuilder.
  class CollectionBuilder < ::Bronze::Collections::CollectionBuilder
    # @param (see Bronze::Collections::CollectionBuilder#initialize)
    # @param @data [Hash] The repository's data hash.
    def initialize collection_type, data
      super(collection_type)

      @data = data
    end # constructor

    # (see Bronze::Collections::CollectionBuilder#collection_class)
    def collection_class
      Bronze::Collections::Reference::Collection
    end # method collection_class

    private

    attr_reader :data

    def build_collection
      collection_class.new(data[collection_name.intern])
    end # method
  end # class
end # module
