# frozen_string_literal: true

require 'bronze/entities'

module Bronze::Entities::Attributes
  # Data class that characterizes an entity attribute and allows for reflection
  # on its properties and options.
  class Metadata
    # @param name [String, Symbol] The name of the attribute.
    # @param type [Class] The type of the attribute.
    # @param options [Hash] Additional options for the attribute.
    def initialize(name, type, options)
      @name        = name.intern
      @type        = type
      @options     = options
      @reader_name = name.intern
      @writer_name = "#{name}=".intern
    end

    # @return [String, Symbol] the name of the attribute.
    attr_reader :name

    # @return [Hash] additional options for the attribute.
    attr_reader :options

    # @return [String, Symbol] the name of the attribute's reader method.
    attr_reader :reader_name

    # @return [Class] the type of the attribute.
    attr_reader :type

    # @return [String, Symbol] the name of the attribute's writer method.
    attr_reader :writer_name

    # @return [Boolean] true if the attribute allows nil values, otherwise
    #   false.
    def allow_nil?
      !!@options[:allow_nil]
    end

    # @return [Object] the default value for the attribute.
    def default
      val = @options[:default]

      val.is_a?(Proc) ? val.call : val
    end
    alias_method :default_value, :default

    # @return [Boolean] true if the default value is set, otherwise false.
    def default?
      !@options[:default].nil?
    end

    # @return [Boolean] true if the attribute does not have a custom transform,
    #   or if the transform is flagged as a default transform; otherwise false.
    def default_transform?
      !!@options[:default_transform] || !transform?
    end

    # @return [Boolean] true if the attribute is a foreign key, otherwise false.
    def foreign_key?
      !!@options[:foreign_key]
    end

    # @return [Boolean] true if the attribute is a primary key, otherwise false.
    def primary_key?
      !!@options[:primary_key]
    end

    # @return [Boolean] true if the attribute is read-only, otherwise false.
    def read_only?
      !!@options[:read_only]
    end

    # @return [Bronze::Transform] the transform used to normalize and
    #   denormalize the attribute.
    def transform
      @options[:transform]
    end

    # @return [Boolean] true if the attribute has a custom transform, otherwise
    #   false.
    def transform?
      !!@options[:transform]
    end
  end
end
