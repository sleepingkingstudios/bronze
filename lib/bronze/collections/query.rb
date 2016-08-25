# lib/bronze/collections/query.rb

require 'bronze/collections'

module Bronze::Collections
  # Abstract class for performing queries against a datastore using a consistent
  # interface, whether it is a SQL database, a Mongoid datastore, or an
  # in-memory data structure.
  class Query
    # Error class for handling unimplemented abstract query methods. Subclasses
    # of Query must implement these methods as appropriate for the datastore.
    class NotImplementedError < StandardError; end

    # The current transform object. The transform maps the raw data returned by
    # the datastore to another object, typically an entity.
    #
    # If a transform is set, it will be used to map all data retrieved from the
    # datastore into the respective entities.
    #
    # @return [Bronze::Entities::Transform] The transform object.
    attr_reader :transform

    # Performs a count on the dataset.
    #
    # @return [Integer] The number of items matching the query.
    def count
      raise NotImplementedError,
        "#{self.class.name} does not implement :count",
        caller
    end # method count

    # Executes the query, if applicable, and returns the results as an array of
    # attribute hashes.
    #
    # @return [Array[Hash]] The data objects matching the query.
    def to_a
      find_each { |hsh| transform.denormalize hsh }
    end # method to_a

    private

    def find_each
      raise NotImplementedError,
        "#{self.class.name} does not implement :find_each",
        caller
    end # method find_each
  end # class
end # module
