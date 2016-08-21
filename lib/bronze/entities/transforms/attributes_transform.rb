# lib/bronze/entities/transforms/attributes_transform.rb

require 'set'
require 'bronze/entities/transforms/transform'

module Bronze::Entities::Transforms
  # Maps an entity to a data hash using the specified attributes.
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

        if superclass <= Bronze::Entities::Transforms::AttributesTransform
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

    # (see ::attribute_names)
    def attribute_names
      self.class.attribute_names
    end # method attribute_names

    # Converts a data hash into an entity instance and sets the value of the
    # entity attribute to the values of the hash for each specified attribute.
    # The entity type is defined by the #entity_class method.
    #
    # @param attributes [Hash] The hash to convert.
    #
    # @return [Bronze::Entities::Entity] The converted entity.
    #
    # @see #entity_class.
    def denormalize attributes
      return entity_class.new if attributes.nil?

      entity = entity_class.new

      attribute_names.each do |attr_name|
        entity.send(:"#{attr_name}=", attributes[attr_name])
      end # each

      entity
    end # method denormalize

    # Converts the entity into a data hash, with the keys being the specified
    # attributes and the values being the entity's values for those attributes.
    #
    # @param entity [Bronze::Entities::Entity] The entity to convert.
    #
    # @return [Hash] The converted data hash.
    def normalize entity
      return {} if entity.nil?

      hsh = {}

      attribute_names.each do |attr_name|
        hsh[attr_name] = entity.send(attr_name)
      end # each

      hsh
    end # method normalize
  end # class
end # module
