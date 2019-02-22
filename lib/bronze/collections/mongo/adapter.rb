# frozen_string_literal: true

require 'bronze/collections/adapter'
require 'bronze/collections/errors'
require 'bronze/collections/mongo'
require 'bronze/collections/mongo/query'
require 'bronze/result'

module Bronze::Collections::Mongo
  # Adapter class that executes against a MongoDB collection.
  class Adapter < Bronze::Collections::Adapter
    Errors = Bronze::Collections::Errors

    # @param [Mongo::Client] client The MongoDB client to query against.
    def initialize(client)
      @client = client
    end

    # (see Bronze::Collections::Adapter#collection_names)
    def collection_names
      # TODO: Implement with Forwardable?
      client.database.collection_names
    end

    # (see Bronze::Collections::Adapter#delete_matching)
    def delete_matching(collection_name, selector)
      result       = Bronze::Result.new([])
      result.value = { count: 0 }

      validate_selector(selector, errors: result.errors)

      return result unless result.success?

      delete_from_collection(collection_name, selector, result: result)
    end

    # (see Bronze::Collections::Adapter#insert_one)
    def insert_one(collection_name, data)
      result       = Bronze::Result.new
      result.value = { count: 0, data: data }

      return result unless validate_attributes(data, errors: result.errors)

      data         = tools.hash.convert_keys_to_strings(data)
      result.value = { count: 1, data: data }

      insert_into_collection(collection_name, data, result: result)
    end

    # (see Bronze::Collections::Adapter#query)
    def query(collection_name)
      Bronze::Collections::Mongo::Query.new(native_collection(collection_name))
    end

    # (see Bronze::Collections::Adapter#update_matching)
    def update_matching(collection_name, selector, data)
      result = Bronze::Result.new
      result.value = { count: 0 }

      validate_selector(selector, errors: result.errors) &&
        validate_attributes(data, errors: result.errors)

      return result unless result.success?

      update_in_collection(collection_name, selector, data, result: result)
    end

    private

    attr_reader :client

    def delete_from_collection(collection_name, selector, result:)
      collection = native_collection(collection_name)
      delete     = collection.delete_many(selector)

      result.value[:count] = delete.n

      result
    end

    def insert_into_collection(collection_name, data, result:)
      collection = native_collection(collection_name)

      collection.insert_one(data)

      result
    end

    def native_collection(name)
      client[name]
    end

    def update_in_collection(collection_name, selector, data, result:)
      collection = native_collection(collection_name)
      update     = collection.update_many(selector, '$set' => data)

      result.value[:count] = update.n

      result
    end

    def validate_attributes(attributes, errors:)
      validate_attributes_not_nil(attributes, errors: errors) &&
        validate_attributes_type(attributes, errors: errors) &&
        validate_attributes_not_empty(attributes, errors: errors)
    end

    def validate_attributes_not_empty(attributes, errors:)
      return true unless attributes.empty?

      errors.add(Errors.data_empty)

      false
    end

    def validate_attributes_not_nil(attributes, errors:)
      return true unless attributes.nil?

      errors.add(Errors.data_missing)

      false
    end

    def validate_attributes_type(attributes, errors:)
      return true if attributes.is_a?(Hash)

      errors.add(Errors.data_invalid, data: attributes)

      false
    end

    def validate_selector(selector, errors:)
      validate_selector_not_nil(selector, errors: errors) &&
        validate_selector_type(selector, errors: errors)
    end

    def validate_selector_not_nil(selector, errors:)
      return true unless selector.nil?

      errors.add(Errors.selector_missing)

      false
    end

    def validate_selector_type(selector, errors:)
      return true if selector.is_a?(Hash)

      errors.add(Errors.selector_invalid, selector: selector)

      false
    end
  end
end
