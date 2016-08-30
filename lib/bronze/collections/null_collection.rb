# lib/bronze/collections/null_collection.rb

require 'bronze/collections/collection'

module Bronze::Collections
  # A collection object representing an empty dataset.
  class NullCollection
    include Bronze::Collections::Collection

    def initialize
      super(nil)
    end # constructorss

    private

    def base_query
      Bronze::Collections::NullQuery.new
    end # method base_query

    def delete_one id
      ["item not found with id #{id.inspect}"]
    end # method delete_one

    def insert_one _attributes
      ['item not inserted']
    end # method insert_one

    def update_one id, _attributes
      ["item not found with id #{id.inspect}"]
    end # method delete_one
  end # class
end # module
