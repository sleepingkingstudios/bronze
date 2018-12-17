# frozen_string_literal: true

require 'bronze/entities'
require 'bronze/entities/attributes/metadata'

module Bronze::Entities::Attributes
  # Service class to define attributes on an entity.
  class Builder
    # Provides a list of the valid options for the attribute_options parameter
    # for Builder#build.
    VALID_OPTIONS = %w[
      allow_nil
      default
      foreign_key
      primary_key
      read_only
      transform
    ].map(&:freeze).freeze

    # @param entity_class [Class] The entity class on which attributes will be
    #   defined.
    def initialize(entity_class)
      @entity_class = entity_class
    end

    # @return [Class] the entity class on which attributes will be defined.
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
    #   builder = Bronze::Entities::Attributes::AttributeBuilder.new(Book)
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
    # @param attribute_options [Hash] Additional options for building the
    #   attribute.
    #
    # @option attribute_options [Object, Proc] :default The default value for
    #   the attribute. If the attribute value is nil or has not been set, the
    #   attribute will be set to the default. If the default is a Proc, the
    #   Proc will be called each time and the attribute set to the return value.
    #   Otherwise, the attribute will be set to the default value.
    # @option attribute_options [Boolean] :foreign_key Marks the attribute as a
    #   foreign key. Will be set to true by association builders, and generally
    #   should not be set manually. Defaults to false.
    # @option attribute_options [Boolean] :read_only If true, the writer method
    #   for the attribute will be set as private. Defaults to false.
    #
    # @return [Attributes::AttributeMetadata] The generated metadata for the
    #   attribute.
    #
    # @raise Builder::Error if the attribute name or attribute type is missing
    #   or invalid.
    def build(attribute_name, attribute_type, attribute_options = {})
      validate_attribute_name(attribute_name)
      validate_attribute_opts(attribute_options)

      characterize(
        attribute_name,
        attribute_type,
        attribute_options
      )
        .tap { |metadata| define_property_methods(metadata) }
    end

    private

    def attributes_module
      @attributes_module ||= define_attributes_module
    end

    def characterize(attribute_name, attribute_type, attribute_options)
      options = {}

      attribute_options.each do |key, value|
        options[key.intern] = value
      end

      Bronze::Entities::Attributes::Metadata.new(
        attribute_name,
        attribute_type,
        attribute_options
      )
    end

    def define_attributes_module
      mod =
        if entity_class.const_defined?(:Attributes, false)
          entity_class::Attributes
        else
          entity_class.const_set(:Attributes, Module.new)
        end

      entity_class.send(:include, mod) unless entity_class < mod

      mod
    end

    def define_property_methods(metadata)
      define_reader(metadata)
      define_writer(metadata)
    end

    def define_reader(metadata)
      attr_name = metadata.name

      attributes_module.send :define_method,
        metadata.reader_name,
        -> { get_attribute(attr_name) }
    end

    def define_writer(metadata)
      attr_name = metadata.name

      attributes_module.send :define_method,
        metadata.writer_name,
        ->(value) { set_attribute(attr_name, value) }

      return unless metadata.read_only?

      attributes_module.send(:private, metadata.writer_name)
    end

    def validate_attribute_name(attribute_name)
      unless attribute_name.is_a?(String) || attribute_name.is_a?(Symbol)
        message = 'expected attribute name to be a String or Symbol, but was ' \
                  "#{attribute_name.inspect}"

        raise ArgumentError, message, caller[1..-1]
      end

      return unless attribute_name.to_s.empty?

      raise ArgumentError, "attribute name can't be blank", caller[1..-1]
    end

    def validate_attribute_opts(attribute_options)
      attribute_options.each do |key, _value|
        next if VALID_OPTIONS.include?(key.to_s)

        raise ArgumentError,
          "invalid attribute option #{key.inspect}",
          caller[1..-1]
      end
    end
  end
end
