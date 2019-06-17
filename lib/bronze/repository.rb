# frozen_string_literal: true

require 'forwardable'

require 'bronze/collection'
require 'bronze/collections/entity_collection'
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
    # @overload collection(name, primary_key:, primary_key_type:, transform:)
    #   @param name [String, Symbol] The name of the data set.
    #   @param primary_key [String, Symbol, false] The name of the primary key
    #     for the data set. If no value is given, defaults to 'id'. A value of
    #     false indicates that the data set does not have a primary key.
    #   @param primary_key_type [Class, String] The type of the primary key for
    #     the data set. If no value is given, defaults to String.
    #   @param transform [Bronze::Transform] The transform used to convert
    #     collection data to and from a usable form, such as an entity class.
    #     Defaults to nil.
    #   @return [Bronze::Collection] the requested collection.
    #
    # @overload collection(entity_class, name:, transform:)
    #   @param item_class [Class] The class corresponding to the data in the
    #     set.
    #   @param name [String, Symbol] The name of the data set. Defaults to the
    #     name of the entity class, formatted as underscore-separated lowercase.
    #   @param transform [Bronze::Transform] The transform used to convert
    #     collection data to and from a usable form, such as an entity class.
    #     Defaults to nil.
    #   @return [Bronze::Collection] the requested collection.
    def collection(
      definition,
      name:             nil,
      primary_key:      nil,
      primary_key_type: nil,
      transform:        nil
    )
      options = { name: name, transform: transform }

      if entity_class?(definition)
        return build_entity_collection(definition, **options)
      end

      build_collection(
        definition,
        **options,
        primary_key:      primary_key,
        primary_key_type: primary_key_type
      )
    end

    private

    def build_collection(
      definition,
      name:,
      primary_key:,
      primary_key_type:,
      transform:
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

    def build_entity_collection(definition, name:, transform:)
      Bronze::Collections::EntityCollection.new(
        definition,
        adapter:   adapter,
        name:      name,
        transform: transform
      )
    end

    def entity_class?(definition)
      definition.is_a?(Class) && definition < Bronze::Entity
    end
  end
end
