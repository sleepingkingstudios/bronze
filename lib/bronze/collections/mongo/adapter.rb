# frozen_string_literal: true

require 'bronze/collections/adapter'
require 'bronze/collections/errors'
require 'bronze/collections/mongo'
require 'bronze/collections/mongo/query'
require 'bronze/errors'

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
      errors = Bronze::Errors.new

      validate_selector(selector, errors: errors)

      return Cuprum::Result.new(error: errors) unless errors.empty?

      delete_from_collection(collection_name, selector)
    end

    # (see Bronze::Collections::Adapter#insert_one)
    def insert_one(collection_name, data)
      errors = Bronze::Errors.new

      validate_attributes(data, errors: errors)

      return Cuprum::Result.new(error: errors) unless errors.empty?

      data = tools.hash.convert_keys_to_strings(data)

      insert_into_collection(collection_name, data)
    end

    # (see Bronze::Collections::Adapter#query)
    def query(collection_name)
      Bronze::Collections::Mongo::Query.new(native_collection(collection_name))
    end

    # (see Bronze::Collections::Adapter#update_matching)
    def update_matching(collection_name, selector, data)
      errors = Bronze::Errors.new

      validate_selector(selector, errors: errors) &&
        validate_attributes(data, errors: errors)

      return Cuprum::Result.new(error: errors) unless errors.empty?

      update_in_collection(collection_name, selector, data)
    end

    private

    attr_reader :client

    def delete_from_collection(collection_name, selector)
      collection = native_collection(collection_name)
      delete     = collection.delete_many(selector)

      Cuprum::Result.new(value: { count: delete.n })
    end

    def insert_into_collection(collection_name, data)
      collection = native_collection(collection_name)

      collection.insert_one(data)

      Cuprum::Result.new(value: { count: 1, data: data })
    end

    def native_collection(name)
      client[name]
    end

    def update_in_collection(collection_name, selector, data)
      collection = native_collection(collection_name)
      update     = collection.update_many(selector, '$set' => data)

      Cuprum::Result.new(value: { count: update.n })
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
