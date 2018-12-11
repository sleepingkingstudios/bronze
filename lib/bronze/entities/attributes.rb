# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/entities'
require 'bronze/entities/attributes/builder'

module Bronze::Entities
  # Module for defining attributes on an entity class.
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
      # @param (see Attributes::AttributeBuilder#build)
      #
      # @option (see Attributes::AttributeBuilder#build)
      #
      # @return (see Attributes::AttributeBuilder#build)
      #
      # @raise (see Attributes::AttributeBuilder#build)
      def attribute(attribute_name, attribute_type, attribute_options = {})
        metadata =
          Bronze::Entities::Attributes::Builder
          .new(self)
          .build(attribute_name, attribute_type, attribute_options)

        (@attributes ||= {})[metadata.name] = metadata
      end

      # Returns the metadata for the attributes defined for the current class.
      #
      # @return [Hash{Symbol => Attributes::Metadata}] the metadata for each
      #   attribute.
      def attributes
        if superclass.respond_to?(:attributes)
          superclass.attributes.merge(@attributes ||= {}).freeze
        else
          (@attributes ||= {}).dup.freeze
        end
      end
    end

    # @param attributes [Hash] The default attributes with which to initialize
    #   the entity. Defaults to an empty hash.
    def initialize(attributes = {})
      initialize_attributes(attributes)
    end

    # @return true if the entity has an attribute with the given name, otherwise
    #   false.
    def attribute?(name)
      self.class.attributes.key?(name&.intern)
    end

    # @param name [String] The name of the attribute.
    #
    # @return [Object] the value of the given attribute.
    def get_attribute(name)
      unless attribute?(name)
        raise ArgumentError, "invalid attribute #{name.inspect}"
      end

      @attributes[name.intern]
    end

    # @param name [String] The name of the attribute.
    # @param value [Object] The new value of the attribute.
    #
    # @return [Object] the new value of the given attribute.
    def set_attribute(name, value)
      unless attribute?(name)
        raise ArgumentError, "invalid attribute #{name.inspect}"
      end

      @attributes[name.intern] = value
    end

    private

    def initialize_attributes(data)
      @attributes = {}

      self.class.attributes.each do |name, metadata|
        value = data[name] || data[name.intern] || metadata.default

        @attributes[name] = value
      end
    end
  end
end
