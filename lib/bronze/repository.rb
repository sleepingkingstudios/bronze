# frozen_string_literal: true

require 'forwardable'

require 'bronze/collection'

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
    #
    # @overload collection(item_class, name:)
    #   @param item_class [Class] The class corresponding to the data in the
    #     set.
    #   @param name [String, Symbol] The name of the data set. Defaults to the
    #     name of the entity class, formatted as underscore-separated lowercase.
    #
    # @return [Bronze::Collection] the requested collection.
    def collection(definition, name: nil)
      Bronze::Collection.new(
        definition,
        adapter: adapter,
        name:    name
      )
    end
  end
end
