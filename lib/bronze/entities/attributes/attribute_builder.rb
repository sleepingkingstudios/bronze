# lib/bronze/entities/attributes/attribute_builder.rb

require 'bronze/entities/attributes/attribute_metadata'

module Bronze::Entities::Attributes
  # Service class to define attributes on an entity.
  class AttributeBuilder
    # Error class for handling invalid attribute definitions.
    class Error < ::StandardError; end

    # Provides a list of the valid options for the builder_options parameter
    # for Builder#build.
    VALID_BUILDER_OPTIONS = %w(
      foreign_key
    ).map(&:freeze).freeze

    # Provides a list of the valid options for the attribute_options parameter
    # for Builder#build.
    VALID_OPTIONS = %w(
      allow_nil
      default
      read_only
    ).map(&:freeze).freeze

    # @param entity_class [Class] The entity class on which attributes will be
    #   defined.
    def initialize entity_class
      @entity_class = entity_class
    end # constructor

    # @return [Class] The entity class on which attributes will be defined.
    attr_reader :entity_class

    # rubocop:disable Metrics/MethodLength

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
    # @option attribute_options [Boolean] :read_only If true, the writer method
    #   for the attribute will be set as private. Defaults to false.
    #
    # @return [Attributes::AttributeMetadata] The generated metadata for the
    #   attribute.
    #
    # @raise Builder::Error if the attribute name or attribute type is missing
    #   or invalid.
    def build(
      attribute_name,
      attribute_type,
      attribute_options = {},
      builder_options = {}
    ) # end arguments
      validate_attribute_name attribute_name
      validate_attribute_opts attribute_options
      validate_builder_opts   builder_options

      attribute_options.update(builder_options)

      metadata = characterize(
        attribute_name,
        attribute_type,
        attribute_options
      ) # end characterize

      define_property_methods(metadata)

      metadata
    end # method build

    # rubocop:enable Metrics/MethodLength

    private

    def characterize attribute_name, attribute_type, attribute_options
      options = {}

      attribute_options.each do |key, value|
        options[key.intern] = value
      end # options

      Bronze::Entities::Attributes::AttributeMetadata.new(
        attribute_name,
        attribute_type,
        attribute_options
      ) # end new
    end # method characterize

    def define_property_methods metadata
      define_reader(metadata)
      define_writer(metadata)
    end # method define_property_methods

    def define_reader metadata
      attr_name = metadata.attribute_name

      entity_class_attributes.send :define_method,
        metadata.reader_name,
        ->() { @attributes[attr_name] ||= metadata.default }
    end # method define_reader

    def define_writer metadata
      attr_name = metadata.attribute_name

      entity_class_attributes.send :define_method,
        metadata.writer_name,
        lambda { |value|
          @attributes[attr_name] = value.nil? ? metadata.default : value
        } # end lambda

      return unless metadata.read_only?

      entity_class_attributes.send :private, metadata.writer_name
    end # define_writer

    def entity_class_attributes
      @entity_class_attributes ||=
        begin
          unless entity_class.send(:attributes_module)
            mod = entity_class.send(:attributes_module=, Module.new)

            entity_class.const_set(:AttributesMethods, mod)

            entity_class.include entity_class::AttributesMethods
          end # unless

          entity_class::AttributesMethods
        end # begin
    end # method entity_class_attributes

    def raise_error error_message
      raise Error, error_message, caller[1..-1]
    end # method raise_error

    def validate_attribute_name attribute_name
      raise_error "attribute name can't be blank" if attribute_name.nil?

      unless attribute_name.is_a?(String) || attribute_name.is_a?(Symbol)
        raise_error 'attribute name must be a String or Symbol'
      end # if

      raise_error "attribute name can't be blank" if attribute_name.empty?
    end # method validate_attribute_name

    def validate_attribute_opts attribute_options
      attribute_options.each do |key, _|
        unless VALID_OPTIONS.include?(key.to_s)
          raise_error "invalid attribute option #{key.inspect}"
        end # unless
      end # each
    end # method validate_attribute_opts

    def validate_builder_opts builder_options
      builder_options.each do |key, _|
        unless VALID_BUILDER_OPTIONS.include?(key.to_s)
          raise_error "invalid builder option #{key.inspect}"
        end # unless
      end # each
    end # method validate_builder_opts
  end # class
end # class
