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
      items  = query(collection_name).matching(selector).to_a

      items.each { |item| collection(collection_name).delete(item) }

      result.value = items

      result
    end

    # (see Bronze::Collections::Adapter#insert_one)
    def insert_one(collection_name, data)
      result       = Bronze::Result.new
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
      result       = Bronze::Result.new([])
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
  end
end
