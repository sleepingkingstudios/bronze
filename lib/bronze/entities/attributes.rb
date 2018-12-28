# lib/bronze/entities/attributes.rb

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/entities'

module Bronze::Entities
  # Namespace for library classes and modules that build and characterize
  # entity attributes.
  module Attributes
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    # Class methods to define when including Attributes in a class.
    module ClassMethods
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
      def attribute attribute_name, attribute_type, attribute_options = {}
        metadata = build_attribute(
          attribute_name,
          attribute_type,
          attribute_options
        ) # end build_attribute

        (@attributes ||= {})[metadata.name] = metadata
      end # class method attribute

      # Returns the metadata for the attributes defined for the current class.
      #
      # @return [Hash{Symbol => Attributes::Metadata}] The metadata for the
      #   attributes.
      def attributes
        if superclass.respond_to?(:attributes)
          superclass.attributes.merge(@attributes ||= {}).freeze
        else
          (@attributes ||= {}).dup.freeze
        end # if-else
      end # class method attributes

      private

      attr_accessor :attributes_module

      def build_attribute(
        attribute_name,
        attribute_type,
        attribute_options
      )
        builder = Bronze::Entities::Attributes::Builder.new(self)
        builder.build(
          attribute_name,
          attribute_type,
          attribute_options
        ) # end build
      end # method build_attribute
    end # module

    # @param attributes [Hash] The default attributes with which to initialize
    #   the entity. Defaults to an empty hash.
    def initialize attributes = {}
      @attributes = {}

      assign_with_defaults attributes.dup, :force => true

      super
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

    # (see #assign)
    def assign_attributes values
      assign values
    end # method assign_attributes

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
      assign_with_defaults values
    end # method attributes=

    private

    # rubocop:disable Metrics/AbcSize
    def assign_with_defaults values, force: false
      missing = self.class.attributes.keys - values.compact.keys.map(&:intern)
      missing.each do |key|
        next if !force && self.class.attributes[key].read_only?

        values[key] = self.class.attributes[key].default_value
      end # each

      assign values
    end # method assign_with_defaults
    # rubocop:enable Metrics/AbcSize

    def get_attribute(name)
      @attributes[name.intern]
    end

    def set_attribute(name, value)
      @attributes[name.intern] = value
    end
  end # module
end # module

require 'bronze/entities/attributes/builder'
