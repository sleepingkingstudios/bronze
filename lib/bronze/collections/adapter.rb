# frozen_string_literal: true

require 'bronze/collections'
require 'bronze/not_implemented_error'

module Bronze::Collections
  # Abstract class defining the interface for collection adapters, which
  # allow collections to interact with different underlying data stores.
  class Adapter
    # Generates a collection name from a Module. By default, the collection name
    # is generated by taking the module #name, converting each segment to
    # snake_case, replacing each :: separator with a double underscore, and
    # pluralizing the final segment.
    #
    # @param mod [Class, Module] The class or module to name.
    #
    # @return [String] the collection name.
    def collection_name_for(mod)
      ary = tools.string.underscore(mod.name).split('::')

      [*ary[0...(ary.size - 1)], tools.string.pluralize(ary.last)].join('__')
    end

    # @return [Array<String>] the names of the collections available to the data
    #   store, such as SQL tables.
    #
    # @raise Bronze::NotImplementedError unless overriden by an Adapter
    #   subclass.
    def collection_names
      raise Bronze::NotImplementedError.new(self, :collection_names)
    end

    # @overload(collection_name, data)
    #   Inserts the data hash into the specified collection.
    #
    #   @param collection_name [String] The collection to insert.
    #   @param data [Hash] The data hash to insert.
    #
    #   @return [Array<Boolean, Hash, Array>] in order, the OK status of the
    #     insert (true or false), the data hash to insert, and an errors array.
    #
    #   @raise Bronze::NotImplementedError unless overriden by an Adapter
    #     subclass.
    def insert_one(_collection_name, _data)
      raise Bronze::NotImplementedError.new(self, :insert_one)
    end

    # @overload(collection_name)
    #   @param collection_name [String] The collection to query.
    #
    #   @return [Bronze::Collections::Query] a query against the specified
    #     collection.
    #
    #   @raise Bronze::NotImplementedError unless overriden by an Adapter
    #     subclass.
    def query(_collection_name)
      raise Bronze::NotImplementedError.new(self, :query)
    end

    private

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
