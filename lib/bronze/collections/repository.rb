# lib/bronze/collections/repository.rb

require 'bronze/collections'

module Bronze::Collections
  # A group of collection objects with a shared data source, such as the
  # various tables of a SQL table or collections of a MongoDB datastore.
  module Repository
    # Error class for handling unimplemented repository methods. Classes that
    # include Repository must implement these methods.
    class NotImplementedError < StandardError; end

    # Builds a new collection using the datastore represented by the repository
    # and the provided transform (if any).
    #
    # @param collection_name [String, Symbol] The name of the collection.
    # @param transform [Bronze::Transforms::Transform] The transform, if any.
    def collection collection_name, transform = nil
      build_collection collection_name, transform
    end # method collection

    private

    def build_collection _collection_name, _transform
      raise NotImplementedError,
        "#{self.class.name} does not implement :build_collection",
        caller
    end # method build_collection
  end # module
end # module
