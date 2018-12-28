# lib/bronze/entities/attributes/attribute_type.rb

require 'bronze/entities/attributes'
require 'bronze/transform'
require 'bronze/transforms/attributes/big_decimal_transform'
require 'bronze/transforms/attributes/date_time_transform'
require 'bronze/transforms/attributes/date_transform'
require 'bronze/transforms/attributes/symbol_transform'
require 'bronze/transforms/attributes/time_transform'

module Bronze::Entities::Attributes
  # Data class that characterizes an attribute type. An attribute type can be
  # either a class or a collection such as an array or hash. If the type is a
  # collection, then all members of the collection must themselves match an
  # attribute type.
  class AttributeType # rubocop:disable Metrics/ClassLength
    VALUE_TYPES = [
      NilClass,
      FalseClass,
      TrueClass,
      Integer,
      Float,
      String
    ].freeze # end value types
    private_constant :VALUE_TYPES

    # @param definition [Class, Array, Hash] The type of collection, in the
    #   format of Class, Array[Object] or Hash[Object, Object].
    def initialize definition
      parse_definition(definition)
    end # constructor

    # @return [AttributeType] The type of each key, or nil if the attribute type
    #   is not a Hash collection.
    attr_reader :key_type

    # @return [AttributeType] The type of each member of the collection, or nil
    #   if the attribute type is not a collection.
    attr_reader :member_type

    # @return [Class] The raw object type, or nil if the attribute type is a
    #   collection.
    attr_reader :object_type

    # @return [Boolean] True if the attribute type is an array, otherwise false.
    def array?
      object_type == Array
    end # method array?

    # @return [Boolean] True if the attribute type is a collection, otherwise
    #   false.
    def collection?
      array? || hash?
    end # method collection?

    # @return [Object] The denormalized value.
    def denormalize value
      return denormalize_array(value) if array?

      return denormalize_hash(value) if hash?

      transform ? transform.denormalize(value) : value
    end # method denormalize

    # @return [Boolean] True if the attribute type is a hash, otherwise false.
    def hash?
      object_type == Hash
    end # method hash?

    # @return [Object] The normalized value.
    def normalize value
      return normalize_array(value) if array?
      return normalize_hash(value)  if hash?

      transform ? transform.normalize(value) : value
    end # method normalize

    private

    attr_accessor :transform

    def denormalize_array ary
      ary.map { |item| member_type.denormalize item }
    end # method denormalize_array

    def denormalize_hash hsh
      hsh.each.with_object({}) do |(key, value), denormalized|
        nkey = key_type.denormalize(key)

        denormalized[nkey] = member_type.denormalize(value)
      end # each
    end # method denormalize_hash

    def normalize_array ary
      ary.map { |item| member_type.normalize item }
    end # method normalize_array

    def normalize_hash hsh
      hsh.each.with_object({}) do |(key, value), normalized|
        nkey = key_type.normalize(key)

        normalized[nkey] = member_type.normalize(value)
      end # each
    end # method normalize_hash

    def parse_array_definition definition
      unless definition.count == 1
        raise ArgumentError,
          'specify exactly one Class as member type'
      end # unless

      @member_type = self.class.new(definition.first)
      @object_type = Array
    end # method parse_array_definition

    def parse_class_definition definition
      @object_type = definition

      return if value_type?(object_type)

      @transform = transform_for(object_type)
    end # method parse_class_definition

    def parse_definition definition
      case definition
      when Hash  then parse_hash_definition(definition)
      when Array then parse_array_definition(definition)
      when Class then parse_class_definition(definition)
      when nil
        raise ArgumentError, "attribute type can't be blank"
      else
        raise ArgumentError, 'attribute type must be a Class'
      end # case
    end # method parse_definition

    # rubocop:disable Metrics/AbcSize
    def parse_hash_definition definition
      unless definition.count == 1
        raise ArgumentError, 'specify exactly one key Class and one value Class'
      end # unless

      unless definition.keys.first.is_a?(Class)
        raise ArgumentError, 'key type must be a Class'
      end # unless

      @key_type    = self.class.new(definition.keys.first)
      @member_type = self.class.new(definition.values.first)
      @object_type = Hash
    end # method parse_hash_definition
    # rubocop:enable Metrics/AbcSize

    def transform_for(object_type) # rubocop:disable Metrics/MethodLength
      case object_type.name
      when 'BigDecimal'
        Bronze::Transforms::Attributes::BigDecimalTransform.instance
      when 'Date'
        Bronze::Transforms::Attributes::DateTransform.instance
      when 'DateTime'
        Bronze::Transforms::Attributes::DateTimeTransform.instance
      when 'Symbol'
        Bronze::Transforms::Attributes::SymbolTransform.instance
      when 'Time'
        Bronze::Transforms::Attributes::TimeTransform.instance
      else
        Bronze::Transform.new
      end
    end

    def value_type? object_type
      VALUE_TYPES.include?(object_type)
    end # method value_type?
  end # class
end # module
