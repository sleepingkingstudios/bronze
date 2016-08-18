# spec/bronze/repositories/reference_collection.rb

require 'bronze/repositories/collection'
require 'bronze/repositories/reference_query'

module Spec
  # A reference implementation of Bronze::Repositories::Collection that uses a
  # Ruby Array as its data source.
  class ReferenceCollection < Bronze::Repositories::Collection
    # @param name [Symbol] The name of the collection.
    # @param data [Array[Hash]] The source data for the collection.
    def initialize name, data
      super(name)

      @data = data
    end # constructor

    private

    def base_query
      ::Spec::ReferenceQuery.new(@data)
    end # method base_query

    def delete_one id
      item = find_item(id)

      return ["item not found with id #{id.inspect}"] unless item

      @data.delete_at(@data.index item)

      []
    end # method delete_one

    def find_item id
      @data.find { |hsh| hsh[:id] == id }
    end # method find_item

    def insert_one attributes
      @data << attributes

      [] # No errors.
    end # method insert_one

    def update_one id, attributes
      item = find_item(id)

      return ["item not found with id #{id.inspect}"] unless item

      item.update attributes

      []
    end # method update_one
  end # class
end # class
