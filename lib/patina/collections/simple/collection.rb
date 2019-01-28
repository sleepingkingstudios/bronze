# lib/patina/collections/simple/collection.rb

require 'bronze/collections/collection'

require 'patina/collections/simple'
require 'patina/collections/simple/query'
require 'patina/collections/validation'

module Patina::Collections::Simple
  # Implementation of Bronze::Collections::Collection for an Array-of-Hashes
  # in-memory data store.
  #
  # @see Simple::Query
  class Collection
    include Bronze::Collections::Collection
    include Patina::Collections::Validation

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

    def clear_collection
      @data.clear

      []
    end # method clear_collection

    def delete_one id
      errors = validate_id_with_presence(id, :present => true)

      return errors unless errors.empty?

      index = @data.index { |hsh| hsh['id'] == id }

      @data.slice!(index)

      []
    end # method delete_one

    def insert_one attributes
      if attributes.is_a?(Hash)
        attributes = tools.hash.convert_keys_to_strings(attributes)
      end

      errors = validate_attributes(attributes)

      return errors unless errors.empty?

      errors = validate_id_with_presence(attributes['id'], :present => false)

      return errors unless errors.empty?

      @data << attributes

      []
    end # method insert_one

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def update_one id, attributes
      if attributes.is_a?(Hash)
        attributes = tools.hash.convert_keys_to_strings(attributes)
      end

      errors = validate_id_with_presence(id, :present => true)

      return errors unless errors.empty?

      errors = validate_attributes(attributes)

      return errors unless errors.empty?

      errors = validate_id_matches(id, attributes)

      return errors unless errors.empty?

      item = @data.find { |hsh| hsh['id'] == id }

      item.update(attributes)

      []
    end # method update_one
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def validate_id_matches id, attributes
      unless attributes['id'].nil? || id == attributes['id']
        return build_errors.add(
          Errors.primary_key_invalid,
          :key      => :id,
          :expected => attributes['id'],
          :received => id
        ) # end errors
      end # unless

      []
    end # method validate_id_matches

    def validate_id_presence id, present:
      if present && !@data.find { |hsh| hsh['id'] == id }
        build_errors.add(Errors.record_not_found, :id => id)
      elsif !present && @data.find { |hsh| hsh['id'] == id }
        build_errors.add(Errors.record_already_exists, :id => id)
      else
        []
      end # if-elsif-else
    end # method validate_id_presence

    def validate_id_with_presence id, present:
      errors = validate_id(id)

      return errors unless errors.empty?

      validate_id_presence(id, :present => present)
    end # method validate_id_with_presence
  end # class
end # class
