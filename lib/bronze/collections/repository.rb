# lib/bronze/collections/repository.rb

require 'bronze/collections'
require 'bronze/collections/collection_builder'

module Bronze::Collections
  # A group of collection objects with a shared data source, such as the
  # various tables of a SQL table or collections of a MongoDB datastore.
  module Repository
    # Error class for handling unimplemented repository methods. Classes that
    # include Repository must implement these methods.
    class NotImplementedError < StandardError; end

    def initialize
      @collection_builder ||= Bronze::Collections::CollectionBuilder
    end # constructor

    # Builds a new collection using the datastore represented by the repository
    # and the provided transform (if any).
    #
    # @param collection_name [String, Symbol] The name of the collection.
    # @param transform [Bronze::Transform] The transform, if any.
    def collection collection_name, transform = nil
      builder    = build_collection collection_name
      collection = builder.build

      transform ||= build_transform builder

      collection.send :repository=, self
      collection.send :transform=,  transform

      collection
    end # method collection

    private

    attr_accessor :collection_builder

    def build_collection collection_name
      collection_builder.new(collection_name)
    end # method build_collection

    def build_transform _collection_builder
      nil
    end # method build_transform
  end # module
end # module
