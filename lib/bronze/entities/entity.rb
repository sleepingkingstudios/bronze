# lib/bronze/entities/entity.rb

require 'bronze/entities/attributes/builder'

require 'bronze/entities/ulid'

module Bronze::Entities
  # Base class for implementing data entities, which store information about
  # business objects without making assumptions about or tying the
  # implementation to any specific framework or data repository.
  class Entity
    # Defines an attribute with the specified name and type.
    #
    # @example Defining an Attribute
    #   class Book < Bronze::Entities::Entity
    #     attribute :title, String
    #   end # class
    #
    #   book.title
    #   #=> nil
    #
    #   book.title = 'Romance of the Three Kingdoms'
    #   book.title
    #   #=> 'Romance of the Three Kingdoms'
    #
    # @param (see Attributes::Builder#build)
    #
    # @option (see Attributes::Builder#build)
    #
    # @return (see Attributes::Builder#build)
    #
    # @raise (see Attributes::Builder#build)
    def self.attribute attribute_name, attribute_type, attribute_options = {}
      builder  = Bronze::Entities::Attributes::Builder.new(self)
      metadata = builder.build(
        attribute_name,
        attribute_type,
        attribute_options
      ) # end build

      (@attributes ||= {})[metadata.attribute_name] = metadata
    end # class method attribute

    # Returns the metadata for the attributes defined for the current class.
    #
    # @return [Hash{Symbol => Attributes::Metadata}] The attributes metadata.
    def self.attributes
      if superclass.respond_to?(:attributes)
        superclass.attributes.merge(@attributes ||= {}).freeze
      else
        (@attributes ||= {}).dup.freeze
      end # if-else
    end # class method attributes

    # @!attribute [r] id
    #   A statistically unique entity identifier string. The id is generated
    #   automatically when the entity is initialized, and does not change
    #   thereafter.
    #
    #   Ids are sortable as strings in ascending order of generation, so
    #   entities can be sorted in order of creation by sorting the ids.
    #
    #   @return [String] The ULID identifier for the entity.
    #
    #   @see Bronze::Entities::Ulid.generate
    attribute :id,
      String,
      :default   => ->() { Bronze::Entities::Ulid.generate },
      :read_only => true

    # @param attributes [Hash] The default attributes with which to initialize
    #   the entity. Defaults to an empty hash.
    def initialize attributes = {}
      @attributes = {}

      self.attributes = attributes.dup
    end # constructor

    # Compares with the other object and returns true if the other object has
    # the same class and attributes.
    def == other
      self.class == other.class && attributes == other.attributes
    end # method ==

    # Merges the values of the attributes. If an attribute is missing, it is not
    # updated. Values that are not valid attributes are discarded.
    #
    # To completely overwrite the attributes hash and set missing attributes to
    # their default values, use #attributes= instead.
    #
    # @param values [Hash{String, Symbol => Object}] The attribute values to
    #   set.
    #
    # @see #attributes=
    def assign values
      values.each do |key, value|
        next unless attribute?(key)

        send("#{key}=", value)
      end # each
    end # method assign

    # Checks if the entity defines the specified attribute.
    #
    # @param attribute_name [String, Symbol] The name of the attribute.
    #
    # @return [Boolean] True if the entity defines the attribute, otherwise
    #   false.
    def attribute? attribute_name
      self.class.attributes.key?(attribute_name.intern)
    end # method attribute?

    # Returns the current value of each attribute.
    #
    # @return [Hash{Symbol => Object}] The attribute values.
    def attributes
      self.class.attributes.each_key.with_object({}) do |attr_name, hsh|
        hsh[attr_name] = send(attr_name)
      end # each
    end # method attributes

    # rubocop:disable Metrics/AbcSize

    # Sets the values of the attributes. If an attribute is missing, it is
    # restored to its default value, or nil if no default value is set for that
    # attribute. Values that are not valid attributes are discarded.
    #
    # To partially overwrite the attributes hash, use #assign instead.
    #
    # @param values [Hash{String, Symbol => Object}] The attribute values to
    #   set.
    #
    # @see #assign.
    def attributes= values
      missing = self.class.attributes.keys - values.keys
      missing.each do |key|
        unless self.class.attributes[key].read_only?
          values[key] = self.class.attributes[key].default_value
        end # unless
      end # each

      assign values
    end # method attributes=
    # rubocop:enable Metrics/AbcSize
  end # class
end # module
