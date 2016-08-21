# lib/bronze/repositories/collection.rb

require 'bronze/entities/transforms/identity_transform'
require 'bronze/repositories'

module Bronze::Repositories
  # A module for wrapping a set of data from a datastore. The data may be a
  # table or view from a SQL database, a collection of documents from a MongoDB
  # datastore, or a simple array of hashes from an in-memory repository, each of
  # which would implement their class that includes Collection.
  #
  # A Collection is responsible for querying data from and persisting data to
  # the datastore. To do so, it must implement (at a minimum) the following
  # methods: base_query, delete_one, insert_one, update_one.
  #
  # (see AbstractCollection)
  module Collection
    attr_accessor :transform

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

    # Deletes the specified hash from the datastore.
    #
    # @param id [Object] The primary key of the hash to delete.
    #
    # @return [Array[Boolean, Hash]] If the update succeeds, returns true and
    #   an empty array. Otherwise, returns false and an array of error messages.
    def delete id
      wrap_errors { delete_one(id) }
    end # method delete

    # Persists the given hash in the datastore.
    #
    # @param attributes [Hash] The hash to persist.
    #
    # @return [Array[Boolean, Hash]] If the insert succeeds, returns true and
    #   an empty array. Otherwise, returns false and an array of error messages.
    def insert attributes
      wrap_errors { insert_one(transform.normalize attributes) }
    end # method insert

    def transform
      @transform ||= Bronze::Entities::Transforms::IdentityTransform.new
    end # method transform

    # Updates the specified hash in the datastore.
    #
    # @param id [Object] The primary key of the hash to update.
    # @param attributes [Hash] The values to update.
    #
    # @return [Array[Boolean, Hash]] If the update succeeds, returns true and
    #   an empty array. Otherwise, returns false and an array of error messages.
    def update id, attributes
      wrap_errors { update_one(id, transform.normalize(attributes)) }
    end # method update

    private

    def wrap_errors
      errors = yield

      [errors.empty?, errors]
    end # method wrap_errors
  end # module
end # module
