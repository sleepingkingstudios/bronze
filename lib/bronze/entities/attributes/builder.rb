# lib/bronze/entities/attributes/builder.rb

require 'bronze/entities/attributes/metadata'

module Bronze::Entities::Attributes
  # Service class to define attributes on an entity.
  class Builder
    # Error class for handling invalid attribute definitions.
    class Error < ::StandardError; end

    # @param entity_class [Class] The entity class on which attributes will be
    #   defined.
    def initialize entity_class
      @entity_class = entity_class
    end # constructor

    # @return [Class] The entity class on which attributes will be defined.
    attr_reader :entity_class

    # Defines an attribute on the entity class.
    #
    # @example Defining an Attribute
    #   class Book < Bronze::Entities::Entity; end
    #
    #   book = Book.new
    #   book.title
    #   #=> NoMethodError: undefined method `title'
    #
    #   builder = Bronze::Entities::Attributes::Builder.new(Book)
    #   builder.define_attribute :title, String
    #
    #   book.title
    #   #=> nil
    #
    #   book.title = 'Romance of the Three Kingdoms'
    #   book.title
    #   #=> 'Romance of the Three Kingdoms'
    #
    # @param attribute_name [Symbol, String] The name of the attribute to
    #   define.
    # @param attribute_type [Class] The type of the attribute to define.
    #
    # @return [Attributes::Metadata] The generated metadata for the attribute.
    #
    # @raise Builder::Error if the attribute name or attribute type is missing
    #   or invalid.
    def build attribute_name, attribute_type
      validate_attribute_name attribute_name
      validate_attribute_type attribute_type

      metadata = characterize attribute_name, attribute_type

      define_reader(metadata)
      define_writer(metadata)

      entity_class.include entity_class_attributes

      metadata
    end # method build

    private

    def characterize attribute_name, attribute_type
      Bronze::Entities::Attributes::Metadata.new(attribute_name, attribute_type)
    end # method characterize

    def define_reader metadata
      attr_name = metadata.attribute_name

      entity_class_attributes.send :define_method,
        metadata.reader_name,
        ->() { @attributes[attr_name] }
    end # method define_reader

    def define_writer metadata
      attr_name = metadata.attribute_name

      entity_class_attributes.send :define_method,
        metadata.writer_name,
        ->(value) { @attributes[attr_name] = value }
    end # define_writer

    def entity_class_attributes
      return @entity_class_attributes if @entity_class_attributes

      unless entity_class.const_defined?(:Attributes)
        entity_class.const_set(:Attributes, Module.new)
      end # unless

      @entity_class_attributes = entity_class::Attributes
    end # method entity_class_attributes

    def raise_error error_message
      raise Builder::Error, error_message, caller[1..-1]
    end # method raise_error

    def validate_attribute_name attribute_name
      raise_error "attribute name can't be blank" if attribute_name.nil?

      unless attribute_name.is_a?(String) || attribute_name.is_a?(Symbol)
        raise_error 'attribute name must be a String or Symbol'
      end # if

      raise_error "attribute name can't be blank" if attribute_name.empty?
    end # method validate_attribute_name

    def validate_attribute_type attribute_type
      raise_error "attribute type can't be blank" if attribute_type.nil?

      unless attribute_type.is_a?(Class)
        raise_error 'attribute type must be a Class'
      end # unless
    end # method validate_attribute_type
  end # class
end # class
