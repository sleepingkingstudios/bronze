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
      @object_type = definition
    end # constructor

    # @return [Class] The raw object type, or nil if the attribute type is a
    #   collection.
    attr_reader :object_type

    # Evaluates whether the object matches the attribute type.
    #
    # @param object [Object] The object to match.
    #
    # @return [Boolean] True if the object matches the attribute type, otherwise
    #   false.
    def matches? object
      object.is_a?(object_type)
    end # method matches?
  end # class
end # module
