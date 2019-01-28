# spec/bronze/collections/reference/collection.rb

require 'bronze/collections/collection'
require 'bronze/collections/reference'
require 'bronze/collections/reference/query'

module Bronze::Collections::Reference
  # Reference implementation of Bronze::Collections::Collection.
  class Collection
    include ::Bronze::Collections::Collection

    # @param transform [Bronze::Entities::Transform] The transform object used
    #   to map collection objects to and from raw data.
    def initialize data, transform = nil
      @data      = data
      @transform = transform
    end # constructor

    private

    def base_query
      Bronze::Collections::Reference::Query.new(@data, transform)
    end # method base_query

    def clear_collection
      @data.clear

      []
    end # method clear_collection

    def delete_one id
      index = @data.index { |hsh| hsh['id'] == id }

      @data.slice!(index)

      []
    end # method delete_one

    def insert_one attributes
      @data << attributes

      []
    end # method insert_one

    def update_one id, attributes
      item = @data.find { |hsh| hsh['id'] == id }

      item.update(attributes)

      []
    end # method update_one
  end # class
end # module
