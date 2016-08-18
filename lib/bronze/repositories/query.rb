# lib/bronze/repositories/query.rb

require 'bronze/repositories'

module Bronze::Repositories
  # Abstract class for performing queries against a datastore using a consistent
  # interface, whether it is a SQL database, a Mongoid datastore, or an
  # in-memory data structure.
  class Query
    # Error class for handling unimplemented abstract query methods. Subclasses
    # of Query must implement these methods as appropriate for the datastore.
    class NotImplementedError < StandardError; end

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
      raise NotImplementedError,
        "#{self.class.name} does not implement :to_a",
        caller
    end # method to_a
  end # class
end # module
