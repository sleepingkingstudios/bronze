# frozen_string_literal: true

require 'bronze/collections'

module Bronze::Collections
  # Methods for handing entity primary keys in a collection.
  module PrimaryKeys
    def initialize(definition, primary_key:, primary_key_type:)
      parse_primary_key(definition)

      @primary_key      = normalize_primary_key(primary_key)
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

      return false if value == false

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
