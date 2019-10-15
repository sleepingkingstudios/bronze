# frozen_string_literal: true

require 'forwardable'

require 'bronze'
require 'bronze/collections/primary_keys'
require 'bronze/collections/validation'
require 'bronze/result'

module Bronze
  # A collection represents a data set, providing a consistent interface to
  # query and manage data from different sources.
  class Collection # rubocop:disable Metrics/ClassLength
    extend Forwardable

    include Bronze::Collections::PrimaryKeys
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
    # @param transform [Bronze::Transform] The transform used to convert
    #   collection data to and from a usable form, such as an entity class.
    #   Defaults to nil.
    #
    # @raise ArgumentError if the definition is not a name or a Class.
    def initialize(
      definition,
      adapter:,
      name:             nil,
      primary_key:      nil,
      primary_key_type: nil,
      transform:        nil
    )
      @adapter = adapter

      super(
        definition,
        primary_key:      primary_key,
        primary_key_type: primary_key_type
      )

      parse_definition(definition)

      @name      = name.to_s unless name.nil?
      @transform = transform unless transform.nil?
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

    # @return [Bronze::Transform] the transform used to convert collection data
    #   to and from a usable form, such as a model class.
    attr_reader :transform

    # Deletes each item in the collection matching the given selector, removing
    # it from the collection.
    #
    # @param selector [Hash] The criteria used to filter the data.
    #
    # @return [Bronze::Result] the result of the delete operation.
    def delete_matching(selector)
      errors = errors_for_selector(selector)

      return Bronze::Result.new(nil, errors: errors) if errors

      denormalize_bulk_result do
        adapter.delete_matching(collection_name: name, selector: selector)
      end
    end

    # Deletes the item in the collection matching the given primary key.
    #
    # @param [Object] value The primary key value to delete.
    #
    # @return [Bronze::Result] the result of the delete operation.
    def delete_one(value)
      errors = errors_for_primary_key_query(value)

      return Bronze::Result.new(nil, errors: errors) if errors

      denormalize_result do
        adapter.delete_one(
          collection_name:   name,
          primary_key:       primary_key,
          primary_key_value: value
        )
      end
    end
    alias_method :delete, :delete_one

    # Finds all items in the collection matching the given selector.
    #
    # @param selector [Hash] The criteria used to filter the data.
    #
    # @return [Bronze::Result] the result of the find operation.
    def find_matching(selector, limit: nil, offset: nil, order: nil)
      errors = errors_for_selector(selector)

      return Bronze::Result.new(nil, errors: errors) if errors

      adapter.find_matching(
        collection_name: name,
        limit:           limit,
        offset:          offset,
        order:           order,
        selector:        selector,
        transform:       transform
      )
    end

    # Finds the data object with the given primary key.
    #
    # @param [Object] value The primary key value to search for.
    #
    # @return [Bronze::Result] the result of the find operation.
    def find_one(value)
      errors = errors_for_primary_key_query(value)

      return Bronze::Result.new(nil, errors: errors) if errors

      adapter.find_one(
        collection_name:   name,
        primary_key:       primary_key,
        primary_key_value: value,
        transform:         transform
      )
    end
    alias_method :find, :find_one

    # Inserts the data hash into the collection.
    #
    # @param data [Hash] The data hash to insert.
    #
    # @return [Bronze::Result] the result of the insert operation.
    def insert_one(data)
      data, errors = normalize_data(data)

      errors ||= errors_for_data(data) || errors_for_primary_key_insert(data)

      return Bronze::Result.new(nil, errors: errors) if errors

      result = adapter.insert_one(collection_name: name, data: data)

      return result unless transform && result.success?

      Bronze::Result.new(transform.denormalize(result.value))
    end
    alias_method :insert, :insert_one

    # @return [Bronze::Collections::NullQuery] a mock query that acts as a
    #     query against an empty collection.
    def null_query
      adapter.null_query(collection_name: name)
    end
    alias_method :none, :null_query

    # Returns a query against the data set.
    #
    # @return [Bronze::Collections::Query] the query instance.
    def query
      adapter.query(
        collection_name: name,
        transform:       transform
      )
    end
    alias_method :all, :query

    # Updates each item in the collection matching the given selector with the
    # specified data.
    #
    # @param selector [Hash] The criteria used to filter the data.
    # @param with [Hash] The keys and values to update in the matching items.
    #
    # @return [Bronze::Result] the result of the update operation.
    def update_matching(selector, with:) # rubocop:disable Metrics/MethodLength
      errors =
        errors_for_selector(selector) ||
        errors_for_data(with) ||
        errors_for_primary_key_bulk_update(with)

      return Bronze::Result.new(nil, errors: errors) if errors

      denormalize_bulk_result do
        adapter.update_matching(
          collection_name: name,
          selector:        selector,
          data:            with
        )
      end
    end

    # Finds and updates the item in the collection with the given primary key.
    #
    # @param value [Object] The primary key value to search for.
    # @param with [Hash] The keys and values to update in the matching items.
    #
    # @return [Bronze::Result] the result of the update operation.
    def update_one(value, with:) # rubocop:disable Metrics/MethodLength
      errors =
        errors_for_primary_key_query(value) ||
        errors_for_data(with) ||
        errors_for_primary_key_update(with, value)

      return Bronze::Result.new(nil, errors: errors) if errors

      denormalize_result do
        adapter.update_one(
          collection_name:   name,
          data:              with,
          primary_key:       primary_key,
          primary_key_value: value
        )
      end
    end
    alias_method :update, :update_one

    private

    def denormalize_bulk_result
      result = yield

      return result unless transform
      return result unless result.success?
      return result unless result.value.is_a?(Hash) && result.value.key?(:data)

      transformed_data =
        result.value[:data].map { |item| transform.denormalize item }

      Cuprum::Result.new(value: result.value.merge(data: transformed_data))
    end

    def denormalize_result
      result = yield

      return result unless transform
      return result unless result.success?

      Bronze::Result.new(transform.denormalize(result.value))
    end

    def normalize_data(data)
      return [data, nil] unless transform

      [transform.normalize(data), nil]
    rescue NoMethodError
      [
        nil,
        build_errors.add(Bronze::Collections::Errors.data_invalid, data: data)
      ]
    end

    def parse_definition(definition)
      return @name = parse_module_name(definition) if definition.is_a?(Module)

      if definition.is_a?(String) || definition.is_a?(Symbol)
        @name = definition.to_s

        return
      end

      raise ArgumentError,
        'expected definition to be a collection name or a class, but was ' \
        "#{definition.inspect}"
    end

    def parse_module_name(mod)
      return mod.collection_name.to_s if mod.respond_to?(:collection_name)

      adapter.collection_name_for(mod)
    end
  end
end
