# frozen_string_literal: true

require 'bronze/collections/adapter'
require 'bronze/collections/errors'
require 'bronze/collections/simple'
require 'bronze/collections/simple/query'
require 'bronze/errors'
require 'bronze/result'

module Bronze::Collections::Simple
  # Adapter class for querying and modifying an in-memory data structure.
  class Adapter < Bronze::Collections::Adapter
    Errors = Bronze::Collections::Errors

    # @param data [Hash<String, Array<Hash>>] The stored data.
    def initialize(data)
      @data = data
    end

    # [Hash<String, Array<Hash>>] the stored data.
    attr_reader :data

    # (see Bronze::Collections::Adapter#collection_names)
    def collection_names
      data.keys.sort
    end

    # (see Bronze::Collections::Adapter#delete_matching)
    def delete_matching(collection_name, selector)
      result = Bronze::Result.new([])

      validate_selector(selector, errors: result.errors)

      return result unless result.success?

      items = query(collection_name).matching(selector).to_a

      items.each { |item| collection(collection_name).delete(item) }

      result.value = items

      result
    end

    # (see Bronze::Collections::Adapter#insert_one)
    def insert_one(collection_name, data)
      result       = Bronze::Result.new
      result.value = data

      return result unless validate_attributes(data, errors: result.errors)

      data         = tools.hash.convert_keys_to_strings(data)
      result.value = data

      insert_into_collection(collection(collection_name), data)

      result
    end

    # (see Bronze::Collections::Adapter#query)
    def query(collection_name)
      Bronze::Collections::Simple::Query.new(collection(collection_name))
    end

    # (see Bronze::Collections::Adapter#update_matching)
    def update_matching(collection_name, selector, data)
      result = Bronze::Result.new([])

      validate_selector(selector, errors: result.errors) &&
        validate_attributes(data, errors: result.errors)

      return result unless result.success?

      data         = tools.hash.convert_keys_to_strings(data)
      result.value =
        query(collection_name).matching(selector).each.map do |item|
          item.update(data)
        end

      result
    end

    private

    def collection(name)
      data[name] ||= []
    end

    def insert_into_collection(collection, object)
      collection << object
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
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
