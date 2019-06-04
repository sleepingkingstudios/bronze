# frozen_string_literal: true

require 'forwardable'

require 'bronze/collection'
require 'bronze/entity'

module Bronze
  # A repository represents a data store, such as a SQL database, a MongoDB
  # datastore, or a set of in-memory objects. Each repository is divided into
  # collections, which correspond to the tables, collections or data series of
  # the data store.
  class Repository
    extend Forwardable

    # @param adapter [Bronze::Collections::Adapter] The adapter used to access
    #   the data store.
    def initialize(adapter:)
      @adapter = adapter
    end

    # @return [Bronze::Collections::Adapter] the adapter used to access the data
    #   store.
    attr_reader :adapter

    def_delegators :@adapter, :collection_names

    # Returns a collection for the requested data set.
    #
    # @overload collection(name)
    #   @param name [String, Symbol] The name of the data set.
    #   @param primary_key [String, Symbol, false] The name of the primary key
    #     for the data set. If no value is given, defaults to 'id'. A value of
    #     false indicates that the data set does not have a primary key.
    #   @param primary_key_type [Class, String] The type of the primary key for
    #     the data set. If no value is given, defaults to String.
    #   @param transform [Bronze::Transform] The transform used to convert
    #     collection data to and from a usable form, such as an entity class.
    #     Defaults to nil.
    #
    # @overload collection(item_class, name:)
    #   @param item_class [Class] The class corresponding to the data in the
    #     set.
    #   @param name [String, Symbol] The name of the data set. Defaults to the
    #     name of the entity class, formatted as underscore-separated lowercase.
    #   @param primary_key [String, Symbol, false] The name of the primary key
    #     for the data set. If no value is given, defaults to the class's
    #     primary key (if any). A value of false indicates that the data set
    #     does not have a primary key.
    #   @param primary_key_type [Class, String] The type of the primary key for
    #     the data set. If no value is given, defaults to the class's primary
    #     key type.
    #   @param transform [Bronze::Transform] The transform used to convert
    #     collection data to and from a usable form, such as an entity class.
    #     Defaults to nil.
    #
    # @return [Bronze::Collection] the requested collection.
    def collection(
      definition,
      name:             nil,
      primary_key:      nil,
      primary_key_type: nil,
      transform:        nil
    )
      Bronze::Collection.new(
        definition,
        adapter:          adapter,
        name:             name,
        primary_key:      primary_key,
        primary_key_type: primary_key_type,
        transform:        transform
      )
    end
  end
end
