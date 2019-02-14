# frozen_string_literal: true

require 'bronze/collections/adapter'
require 'bronze/collections/errors'
require 'bronze/collections/simple'
require 'bronze/collections/simple/query'
require 'bronze/errors'

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

    # (see Bronze::Collections::Adapter#insert_one)
    def insert_one(collection_name, data)
      errors = build_errors

      unless validate_attributes(data, errors: errors)
        return [false, data, errors]
      end

      data = tools.hash.convert_keys_to_strings(data)

      insert_into_collection(collection(collection_name), data)

      [errors.empty?, data, errors]
    end

    # (see Bronze::Collections::Adapter#query)
    def query(collection_name)
      Bronze::Collections::Simple::Query.new(collection(collection_name))
    end

    private

    def build_errors
      Bronze::Errors.new
    end

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

      errors.add(Errors.data_invalid)

      false
    end
  end
end