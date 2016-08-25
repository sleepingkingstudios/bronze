# lib/patina/collections/simple/collection.rb

require 'bronze/collections/collection'
require 'patina/collections/simple/query'

module Patina::Collections::Simple
  # Implementation of Bronze::Collections::Collection for an Array-of-Hashes
  # in-memory data store.
  #
  # @see Simple::Query
  class Collection
    include Bronze::Collections::Collection

    def initialize
      @data = []
    end # constructor

    private

    def base_query
      Patina::Collections::Simple::Query.new(@data, transform)
    end # method base_query

    def delete_one id
      errors = validate_id(id, :present => true)

      return errors unless errors.empty?

      index = @data.index { |hsh| hsh[:id] == id }

      @data.slice!(index)

      []
    end # method delete_one

    def insert_one attributes
      errors = validate_attributes(attributes)

      return errors unless errors.empty?

      errors = validate_id(attributes[:id], :present => false)

      return errors unless errors.empty?

      @data << attributes

      []
    end # method insert_one

    def update_one id, attributes
      errors = validate_id(id, :present => true)

      return errors unless errors.empty?

      errors = validate_attributes(attributes)

      return errors unless errors.empty?

      unless attributes[:id].nil? || id == attributes[:id]
        return ['data id must match id']
      end # unless

      item = @data.find { |hsh| hsh[:id] == id }

      item.update(attributes)

      []
    end # method update_one

    def validate_attributes attributes
      return ["data can't be nil"] if attributes.nil?

      return ['data must be a Hash'] unless attributes.is_a?(Hash)

      []
    end # method validate_attributes

    def validate_id id, present: nil
      return ["id can't be nil"] if id.nil?

      return [] if present.nil?

      validate_id_presence id, :present => present
    end # method validate_idy

    def validate_id_presence id, present:
      if present && !@data.find { |hsh| hsh[:id] == id }
        ["item not found with id #{id.inspect}"]
      elsif !present && @data.find { |hsh| hsh[:id] == id }
        ['id already exists']
      else
        []
      end # if-elsif-else
    end # method validate_id_presense
  end # class
end # class
