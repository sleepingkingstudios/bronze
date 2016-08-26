# lib/bronze/collections/collection.rb

require 'bronze/collections'
require 'bronze/transforms/copy_transform'
require 'sleeping_king_studios/tools/toolbox/delegator'

module Bronze::Collections
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
    extend SleepingKingStudios::Tools::Toolbox::Delegator

    # @param transform [Bronze::Entities::Transform] The transform object used
    #   to map collection objects to and from raw data.
    def initialize transform = nil
      @transform = transform
    end # constructor

    # @!method count
    #   (see Bronze::Collections::Query#count)
    delegate :count, :to => :base_query

    # Returns the default query object for the collection.
    #
    # @return [Query] The default query.
    def all
      base_query
    end # method all

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

    # The current transform object. The transform maps the raw data sent to or
    # returned by the datastore to another object, typically an entity.
    #
    # If a transform is set, it will be used to map all entities passed into
    # persistence methods (e.g. #insert and #update) into into raw data, and to
    # map all data retrieved via query methods (e.g. #all or #query) into the
    # respective entities.
    #
    # @return [Bronze::Transform] The transform object.
    def transform
      @transform ||= Bronze::Transforms::CopyTransform.new
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

    attr_writer :transform

    def wrap_errors
      errors = yield

      [errors.empty?, errors]
    end # method wrap_errors
  end # module
end # module
