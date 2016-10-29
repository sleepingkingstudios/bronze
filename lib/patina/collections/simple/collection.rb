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

    # @param transform [Bronze::Entities::Transform] The transform object used
    #   to map collection objects to and from raw data.
    def initialize data, transform = nil
      @data      = data
      @transform = transform
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

      errors = validate_id_matches(id, attributes)

      return errors unless errors.empty?

      item = @data.find { |hsh| hsh[:id] == id }

      item.update(attributes)

      []
    end # method update_one

    def validate_attributes attributes
      return build_errors.add(Errors.data_missing) if attributes.nil?

      unless attributes.is_a?(Hash)
        return build_errors.add(Errors.data_invalid, :attributes => attributes)
      end # unless

      []
    end # method validate_attributes

    def validate_id id, present: nil
      if id.nil?
        return build_errors.add(Errors.primary_key_missing, :key => :id)
      end # if

      return [] if present.nil?

      validate_id_presence id, :present => present
    end # method validate_id

    def validate_id_matches id, attributes
      unless attributes[:id].nil? || id == attributes[:id]
        return build_errors.add(
          Errors.primary_key_invalid,
          :key      => :id,
          :expected => attributes[:id],
          :received => id
        ) # end errors
      end # unless

      []
    end # method validate_id_matches

    def validate_id_presence id, present:
      if present && !@data.find { |hsh| hsh[:id] == id }
        build_errors.add(Errors.record_not_found, :id => id)
      elsif !present && @data.find { |hsh| hsh[:id] == id }
        build_errors.add(Errors.record_already_exists, :id => id)
      else
        []
      end # if-elsif-else
    end # method validate_id_presense
  end # class
end # class
