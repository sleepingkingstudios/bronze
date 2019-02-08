# frozen_string_literal: true

require 'forwardable'

require 'bronze/collections'

module Bronze::Collections
  # A collection represents a data set, providing a consistent interface to
  # query and manage data from different sources.
  class Collection
    extend Forwardable

    # @param definition [Class, String] The name of the data set, used to pull
    #   the data from the data store.
    # @param adapter [Bronze::Collections::Adapter] The adapter used to access
    #   the data store.
    def initialize(definition, adapter:)
      @adapter = adapter
      @name    = parse_name(definition)
    end

    def_delegators :query,
      :count,
      :each,
      :matching

    alias_method :where, :matching

    # @return [Bronze::Collections::Adapter] the adapter used to access the data
    #   store.
    attr_reader :adapter

    # @return [String] the name of the data set.
    attr_reader :name

    # Returns a query against the data set.
    #
    # @return [Bronze::Collections::Query] the query instance.
    def query
      adapter.query(name)
    end
    alias_method :all, :query

    private

    def collection_name_for(definition)
      ary = tools.string.underscore(definition.name).split('::')

      [*ary[0...(ary.size - 1)], tools.string.pluralize(ary.last)].join('__')
    end

    def parse_name(definition)
      return definition.to_s unless definition.is_a?(Module)

      if definition.respond_to?(:collection_name)
        return definition.collection_name
      end

      collection_name_for(definition)
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
