# lib/bronze/entities/attributes/attribute_type.rb

require 'bronze/entities/attributes'

module Bronze::Entities::Attributes
  # Data class that characterizes an attribute type. An attribute type can be
  # either a class or a collection such as an array or hash. If the type is a
  # collection, then all members of the collection must themselves match an
  # attribute type.
  class AttributeType
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

    # @return [Boolean] True if the attribute type is a collection, otherwise
    #   false.
    def collection?
      @collection
    end # method collection?

    private

    def parse_array_definition definition
      unless definition.count == 1
        raise ArgumentError,
          'specify exactly one Class as member type'
      end # unless

      @collection  = true
      @member_type = self.class.new(definition.first)
      @object_type = Array
    end # method parse_array_definition

    def parse_class_definition definition
      @collection  = false
      @object_type = definition
    end # method parse_class_definition

    def parse_hash_definition definition
      unless definition.count == 1
        raise ArgumentError, 'specify exactly one key Class and one value Class'
      end # unless

      @collection = true
      @key_type   = definition.keys.first

      unless @key_type.is_a?(Class)
        raise ArgumentError, 'key type must be a Class'
      end # unless

      @member_type = self.class.new(definition.values.first)
      @object_type = Hash
    end # method parse_hash_definition

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
  end # class
end # module
