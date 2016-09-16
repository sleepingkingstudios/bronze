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
    # @param transform [Bronze::Transforms::Transform] The transform, if any.
    def collection collection_name, transform = nil
      collection = build_collection collection_name, transform

      collection.send :repository=, self

      collection
    end # method collection

    private

    attr_accessor :collection_builder

    def build_collection collection_name, transform
      collection_builder.new(collection_name).build(transform)
    end # method build_collection
  end # module
end # module
