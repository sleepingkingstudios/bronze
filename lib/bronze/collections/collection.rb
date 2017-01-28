# lib/bronze/collections/collection.rb

require 'sleeping_king_studios/tools/toolbox/constant_map'
require 'sleeping_king_studios/tools/toolbox/delegator'

require 'bronze/collections'
require 'bronze/errors/errors'
require 'bronze/transforms/copy_transform'

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

    errors = ::SleepingKingStudios::Tools::Toolbox::ConstantMap.new(
      :DATA_INVALID          => :data_invalid,
      :DATA_MISSING          => :data_missing,
      :PRIMARY_KEY_INVALID   => :primary_key_invalid,
      :PRIMARY_KEY_MISSING   => :primary_key_missing,
      :READ_ONLY_COLLECTION  => :read_only_collection,
      :RECORD_ALREADY_EXISTS => :record_already_exists,
      :RECORD_NOT_FOUND      => :record_not_found
    ).freeze # end hash

    const_set(:Errors, errors)

    # @param transform [Bronze::Entities::Transform] The transform object used
    #   to map collection objects to and from raw data.
    def initialize transform = nil
      @transform = transform
    end # constructor

    # @return [String, Symbol] The name of the collection's root resource.
    attr_reader :resource_name

    # @!method count
    #   (see Bronze::Collections::Query#count)

    # @!method each
    #   (see Bronze::Collections::Query#each)

    # @!method exists?
    #   (see Bronze::Collections::Query#exists?)

    # @!method limit(count)
    #   (see Bronze::Collections::Query#limit)

    # @!method matching(selector)
    #   Returns a copy of the default query object with an added match criteria.
    #
    #   @param selector [Hash] The properties and values that the returned data
    #     must match.
    #
    #   @return [Query] The query with match criteria.

    # @!method none
    #   (see Bronze::Collections::Query#none)

    # @!method one
    #   (see Bronze::Collections::Query#one)

    # @!method pluck(attribute_name)
    #   (see Bronze::Collections::Query#pluck)

    # @!method to_a
    #   (see Bronze::Collections::Query#to_a)
    delegate \
      :count,
      :each,
      :exists?,
      :limit,
      :matching,
      :one,
      :none,
      :pluck,
      :to_a,
      :to => :base_query

    # @return [String] The name of the collection. Usually, the collection name
    # is the plural form of the data it represents, e.g. a collection of Book
    # objects should be named 'books'.
    attr_reader :name

    # @return [Bronze::Collections::Repository] The repository to which the
    #   collection belongs.
    attr_reader :repository

    # Deletes the specified hash from the datastore.
    #
    # @param id [Object] The primary key of the hash to delete.
    #
    # @return [Array[Boolean, Hash]] If the update succeeds, returns true and
    #   an empty array. Otherwise, returns false and an array of error messages.
    def delete id
      wrap_errors { delete_one(id) }
    end # method delete

    # Queries for and returns the resource hash with the requested id from the
    #   datastore.
    def find id
      base_query.matching(:id => id).limit(2).one
    end # method find

    # Persists the given hash in the datastore.
    #
    # @param attributes [Hash] The hash to persist.
    #
    # @return [Array[Boolean, Hash]] If the insert succeeds, returns true and
    #   an empty array. Otherwise, returns false and an array of error messages.
    def insert attributes
      wrap_errors { insert_one(transform.normalize attributes) }
    end # method insert

    # Returns the default query object for the collection.
    #
    # @return [Query] The default query.
    def query
      base_query
    end # method query

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
      @transform ||= default_transform
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

    protected

    attr_writer :name
    attr_writer :repository
    attr_writer :transform

    private

    def build_errors
      ::Bronze::Errors::Errors.new
    end # method build_errors

    def default_transform
      Bronze::Transforms::CopyTransform.new
    end # method default_transform

    def wrap_errors
      errors = yield

      [errors.empty?, errors]
    end # method wrap_errors
  end # module
end # module
