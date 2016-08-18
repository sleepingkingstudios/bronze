# lib/bronze/repositories/collection.rb

require 'bronze/repositories'

module Bronze::Repositories
  # A base class for wrapping a set of data from a datastore. The data may be a
  # table or view from a SQL database, a collection of documents from a MongoDB
  # datastore, or a simple array of hashes from an in-memory repository, each of
  # which would implement their own subclass of Collection.
  #
  # A Collection is responsible for querying data from and persisting data to
  # the datastore.
  class Collection
    # Error class for handling unimplemented abstract collection methods.
    # Subclasses of Collection must implement these methods as appropriate for
    # the datastore.
    class NotImplementedError < StandardError; end

    # @param name [Symbol] The name of the collection.
    def initialize name
      @name = name
    end # constructor

    # @return [Symbol] The name of the collection.
    attr_reader :name

    # Returns the default query object for the collection.
    #
    # @return [Query] The default query.
    def all
      base_query
    end # method all

    # Performs a count on the dataset.
    #
    # @return [Integer] The number of items matching the query.
    def count
      base_query.count
    end # method count

    private

    def base_query
      raise NotImplementedError,
        "#{self.class.name} does not implement :base_query",
        caller
    end # method base_query
  end # class
end # module
