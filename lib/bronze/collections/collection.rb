# frozen_string_literal: true

require 'forwardable'

require 'bronze/collections'

module Bronze::Collections
  # A collection represents a data set, providing a consistent interface to
  # query and manage data from different sources.
  class Collection
    extend Forwardable

    # @param definition [Class, String] An object defining the data to access.
    #   Can be a String (the name of the data set) or a Class (the objects
    #   represented by the data set).
    # @param adapter [Bronze::Collections::Adapter] The adapter used to access
    #   the data store.
    # @param name [String, Symbol] The name of the data set, used to pull
    #   the data from the data store. Unless specified, defaults to the
    #   definition (if a String) or the name of the definition class.
    #
    # @raise ArgumentError if the definition is not a name or a Class.
    def initialize(definition, adapter:, name: nil)
      @adapter = adapter
      @name    = name.nil? ? nil : name.to_s

      parse_definition(definition)
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

    def parse_definition(definition)
      return parse_module_definition(definition) if definition.is_a?(Module)

      if definition.is_a?(String) || definition.is_a?(Symbol)
        @name ||= definition.to_s

        return
      end

      raise ArgumentError,
        'expected definition to be a collection name or a class, but was ' \
        "#{definition.inspect}"
    end

    # rubocop:disable Naming/MemoizedInstanceVariableName
    def parse_module_definition(mod)
      @name ||=
        if mod.respond_to?(:collection_name)
          mod.collection_name.to_s
        else
          collection_name_for(mod)
        end
    end
    # rubocop:enable Naming/MemoizedInstanceVariableName

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
