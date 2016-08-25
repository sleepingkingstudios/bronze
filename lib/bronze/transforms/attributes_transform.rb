# lib/bronze/transforms/attributes_transform.rb

require 'set'
require 'bronze/transforms/transform'

module Bronze::Transforms
  # Maps an object to a data hash using the specified attributes.
  class AttributesTransform < Transform
    class << self
      # Adds the named attribute to the attributes set.
      #
      # @param attr_name [String, Symbol] The attribute name.
      #
      # @see ::attributes
      def attribute attr_name
        (@attribute_names ||= Set.new) << attr_name.intern
      end # class method attribute

      # Returns the set of attribute names. Only the named attributes will be
      # used to map an entity into a data hash and vice versa.
      #
      # @return [Set] The attribute names.
      def attribute_names
        @attribute_names ||= Set.new

        if superclass <= Bronze::Transforms::AttributesTransform
          superclass.attribute_names + @attribute_names
        else
          @attribute_names
        end # if-else
      end # method attribute_names

      # Adds the named attributes to the attributes set and returns the set.
      #
      # @param attr_names[Array[String, Symbol]] The names of the attributes
      #   to add to the set.
      #
      # @return [Set] The attribute names.
      def attributes *attr_names
        @attribute_names ||= Set.new

        attr_names.each { |attr_name| @attribute_names << attr_name.intern }
      end # class method attributes
    end # eigenclass

    attribute :id

    # @param object_class [Class] The class into which data hashes will be
    #   denormalized.
    def initialize object_class
      @object_class = object_class
    end # constructor

    # @return [Class] The class into which data hashes will be denormalized.
    attr_reader :object_class

    # (see AttributesTransform.attribute_names)
    def attribute_names
      self.class.attribute_names
    end # method attribute_names

    # Converts a data hash into an object instance and sets the values of the
    # object attributes to the values of the hash for each specified attributes.
    # The object type is defined by the #object_class method.
    #
    # @param attributes [Hash] The hash to convert.
    #
    # @return [Object] The converted object.
    #
    # @see #object_class.
    def denormalize attributes
      return object_class.new if attributes.nil?

      object = object_class.new

      attribute_names.each do |attr_name|
        object.send(:"#{attr_name}=", attributes[attr_name])
      end # each

      object
    end # method denormalize

    # Converts the object into a data hash, with the keys being the specified
    # attributes and the values being the object's values for those attributes.
    #
    # @param object [Object] The object to convert.
    #
    # @return [Hash] The converted data hash.
    def normalize object
      return {} if object.nil?

      hsh = {}

      attribute_names.each do |attr_name|
        hsh[attr_name] = object.send(attr_name)
      end # each

      hsh
    end # method normalize
  end # class
end # module
