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

    # Persists the given hash in the datastore.
    #
    # @param attributes [Hash] The hash to persist.
    #
    # @return [Array[Boolean, Hash]] If the insert succeeds, returns true and
    #   an empty array. Otherwise, returns false and an array of error messages.
    def insert attributes
      errors = insert_attributes(attributes)

      [errors.empty?, errors]
    end # method insert
    alias_method :create, :insert

    # Updates the specified hash in the datastore.
    #
    # @param id [Object] The primary key of the hash to update.
    # @param attributes [Hash] The values to update.
    #
    # @return [Array[Boolean, Hash]] If the update succeeds, returns true and
    #   an empty array. Otherwise, returns false and an array of error messages.
    def update id, attributes
      errors = update_attributes(id, attributes)

      [errors.empty?, errors]
    end # method update

    private

    def base_query
      not_implemented :base_query
    end # method base_query

    def insert_attributes _attributes
      not_implemented :insert_attributes
    end # method insert_attributes

    def not_implemented method_name
      raise NotImplementedError,
        "#{self.class.name} does not implement :#{method_name}",
        caller[1..-1]
    end # method not_implemented

    def update_attributes _id, _attributes
      not_implemented :update_attributes
    end # method update_attributes
  end # class
end # module
