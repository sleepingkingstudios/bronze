# frozen_string_literal: true

require 'bronze/collections'

module Bronze::Collections
  # Methods for handing entity primary keys in a collection.
  module PrimaryKeys
    # @param definition [Class, String] An object defining the data to access.
    #   Can be a String (the name of the data set) or a Class (the objects
    #   represented by the data set).
    # @param primary_key [String, Symbol, false] The name of the primary key for
    #   the data set. If no value is given, defaults to 'id'. A value of false
    #   indicates that the data set does not have a primary key.
    # @param primary_key_type [Class, String] The type of the primary key for
    #   the data set. If no value is given, defaults to String.
    def initialize(definition, primary_key:, primary_key_type:)
      parse_primary_key(definition)

      @primary_key = normalize_primary_key(primary_key)

      return if primary_key == false

      @primary_key_type = normalize_primary_key_type(primary_key_type)
    end

    # @return [String, false] the name of the primary key for the data set.
    attr_reader :primary_key

    # @return [Class] the type of the primary key for the data set.
    attr_reader :primary_key_type

    # @return [Boolean] true if the collection has a primary key, otherwise
    #   false.
    def primary_key?
      !!@primary_key
    end

    private

    def default_primary_key
      :id
    end

    def default_primary_key_type
      String
    end

    def normalize_primary_key(value)
      return @primary_key || default_primary_key if value.nil?

      return nil if value == false

      return value if value.is_a?(Symbol)

      return value.intern if value.is_a?(String)

      raise ArgumentError,
        'expected primary key to be a String, a Symbol or false, but was ' \
        "#{value.inspect}"
    end

    def normalize_primary_key_type(type)
      return @primary_key_type || default_primary_key_type if type.nil?

      return type if type.is_a?(Class)

      Object.const_get(type)
    end

    def parse_primary_key(definition)
      return unless definition.is_a?(Module) &&
                    definition.respond_to?(:primary_key)

      metadata = definition.primary_key

      @primary_key      = metadata&.name
      @primary_key_type = metadata&.type
    end
  end
end
