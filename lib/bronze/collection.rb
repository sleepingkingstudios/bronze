# frozen_string_literal: true

require 'forwardable'

require 'bronze'
require 'bronze/collections/validation'
require 'bronze/result'

module Bronze
  # A collection represents a data set, providing a consistent interface to
  # query and manage data from different sources.
  class Collection
    extend Forwardable

    include Bronze::Collections::Validation

    # @param definition [Class, String] An object defining the data to access.
    #   Can be a String (the name of the data set) or a Class (the objects
    #   represented by the data set).
    # @param adapter [Bronze::Collections::Adapter] The adapter used to access
    #   the data store.
    # @param name [String, Symbol] The name of the data set, used to pull
    #   the data from the data store. Unless specified, defaults to the
    #   definition (if a String) or the name of the definition class.
    # @param primary_key [String, Symbol, false] The name of the primary key for
    #   the data set. If no value is given, defaults to 'id'. A value of false
    #   indicates that the data set does not have a primary key.
    # @param primary_key_type [Class, String] The type of the primary key for
    #   the data set. If no value is given, defaults to String.
    #
    # @raise ArgumentError if the definition is not a name or a Class.
    def initialize(
      definition,
      adapter:,
      name:             nil,
      primary_key:      nil,
      primary_key_type: nil
    )
      @adapter = adapter

      parse_definition(definition)

      @name             = name.to_s unless name.nil?
      @primary_key      = normalize_primary_key(primary_key)
      @primary_key_type = normalize_primary_key_type(primary_key_type)
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

    # @return [String, false] the name of the primary key for the data set.
    attr_reader :primary_key

    # @return [Class] the type of the primary key for the data set.
    attr_reader :primary_key_type

    # Deletes each item in the collection matching the given selector, removing
    # it from the collection.
    #
    # @param selector [Hash] The criteria used to filter the data.
    #
    # @return [Array<Boolean, Hash, Array>] in order, the OK status of the
    #   delete (true or false), the deleted items, and an errors array.
    def delete_matching(selector)
      errors = errors_for_selector(selector)

      return Bronze::Result.new(nil, errors: errors) if errors

      adapter.delete_matching(name, selector)
    end

    # Inserts the data hash into the collection.
    #
    # @param data [Hash] The data hash to insert.
    #
    # @return [Array<Boolean, Hash, Array>] in order, the OK status of the
    #   insert (true or false), the data hash to insert, and an errors array.
    def insert_one(data)
      errors = errors_for_data(data) || errors_for_primary_key_insert(data)

      return Bronze::Result.new(nil, errors: errors) if errors

      adapter.insert_one(name, data)
    end

    # @return [Boolean] true if the collection has a primary key, otherwise
    #   false.
    def primary_key?
      !!@primary_key
    end

    # Returns a query against the data set.
    #
    # @return [Bronze::Collections::Query] the query instance.
    def query
      adapter.query(name)
    end
    alias_method :all, :query

    # Updates each item in the collection matching the given selector with the
    # specified data.
    #
    # @param selector [Hash] The criteria used to filter the data.
    # @param with [Hash] The keys and values to update in the matching items.
    #
    # @return [Array<Boolean, Hash, Array>] in order, the OK status of the
    #   update (true or false), the updated items, and an errors array.
    def update_matching(selector, with:)
      errors = errors_for_selector(selector) || errors_for_data(with)

      return Bronze::Result.new(nil, errors: errors) if errors

      adapter.update_matching(name, selector, with)
    end

    private

    def default_primary_key
      :id
    end

    def default_primary_key_type
      String
    end

    def normalize_primary_key(value)
      return @primary_key || default_primary_key if value.nil?

      return false if value == false

      return value if value.is_a?(Symbol)

      return value.intern if value.is_a?(String)

      raise ArgumentError,
        'expected primary key to be a String, a Symbol or false, but was ' \
        "#{value.inspect}"
    end

    def normalize_primary_key_type(type)
      return @primary_key_type || default_primary_key_type if type.nil?

      return type if type.is_a?(Class)

      Object.const_get(type)
    end

    def parse_definition(definition)
      return parse_module_definition(definition) if definition.is_a?(Module)

      if definition.is_a?(String) || definition.is_a?(Symbol)
        @name = definition.to_s

        return
      end

      raise ArgumentError,
        'expected definition to be a collection name or a class, but was ' \
        "#{definition.inspect}"
    end

    def parse_module_definition(mod)
      @name =
        if mod.respond_to?(:collection_name)
          mod.collection_name.to_s
        else
          adapter.collection_name_for(mod)
        end

      return unless mod.respond_to?(:primary_key)

      metadata = mod.primary_key

      @primary_key      = metadata&.name
      @primary_key_type = metadata&.type
    end
  end
end
