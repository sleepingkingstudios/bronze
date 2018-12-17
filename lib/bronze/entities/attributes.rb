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
      #   class Book
      #     include Bronze::Entities::Attributes
      #
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
      #
      # @note This method allocates a new hash each time it is called and is not
      #   cached. To loop through the attributes, use the ::each_attribute
      #   method instead.
      def attributes
        each_attribute
          .with_object({}) do |(name, metadata), hsh|
            hsh[name] = metadata
          end
          .freeze
      end

      # @overload each_attribute
      #   Returns an enumerator that iterates through the attributes defined on
      #   the entity class and any parent classes.
      #
      #   @return [Enumerator] the enumerator.
      #
      # @overload each_attribute
      #   Iterates through the attributes defined on the entity class and any
      #   parent classes, and yields the name and metadata of each attribute to
      #   the block.
      #
      #   @yieldparam name [Symbol] The name of the attribute.
      #   @yieldparam name [Bronze::Entities::Attributes::Metadata] The metadata
      #     for the attribute.
      def each_attribute
        return enum_for(:each_attribute) unless block_given?

        if superclass.respond_to?(:each_attribute)
          superclass.each_attribute { |name, metadata| yield(name, metadata) }
        end

        (@attributes ||= {}).each { |name, metadata| yield(name, metadata) }
      end
    end

    # @param attributes [Hash] The default attributes with which to initialize
    #   the entity. Defaults to an empty hash.
    def initialize(attributes = {})
      initialize_attributes(attributes)
    end

    # Compares with the other object.
    #
    # If the other object is a Hash, returns true if the entity attributes hash
    # is equal to the given hash. Otherwise, returns true if the other object
    # has the same class and attributes as the entity.
    #
    # @param other [Bronze::Entities::Attributes, Hash] The object to compare.
    #
    # @return [Boolean] true if the other object matches the entity, otherwise
    #   false.
    def ==(other)
      return attributes == other if other.is_a?(Hash)

      other.class == self.class && other.attributes == attributes
    end

    # Updates the attributes with the given hash. If an attribute is not in the
    # hash, it is unchanged.
    #
    # @raise ArgumentError if one of the keys is not a valid attribute
    def assign_attributes(hash)
      validate_attributes(hash)

      self.class.each_attribute do |name, metadata|
        next if metadata.read_only?
        next unless hash.key?(name) || hash.key?(name.to_s)

        set_attribute(name, hash[name] || hash[name.to_s])
      end
    end
    alias_method :assign, :assign_attributes

    # @return true if the entity has an attribute with the given name, otherwise
    #   false.
    def attribute?(name)
      attribute_name = name.intern

      self.class.each_attribute.any? { |key, _metadata| key == attribute_name }
    rescue NoMethodError
      raise ArgumentError, "invalid attribute #{name.inspect}"
    end

    # Returns the current value of each attribute.
    #
    # @return [Hash{Symbol => Object}] the attribute values.
    def attributes
      each_attribute.with_object({}) do |attr_name, hsh|
        hsh[attr_name] = get_attribute(attr_name)
      end
    end

    # Replaces the attributes with the given hash. If a non-primary key
    # attribute is not in the hash, it is set to nil.
    #
    # @raise ArgumentError if one of the keys is not a valid attribute
    def attributes=(hash)
      validate_attributes(hash)

      self.class.each_attribute do |name, metadata|
        next if metadata.primary_key?

        @attributes[name] = hash[name] || hash[name.to_s]
      end
    end

    # @param name [String] The name of the attribute.
    #
    # @return [Object] the value of the given attribute.
    #
    # @raise ArgumentError when the attribute name is not a valid attribute
    def get_attribute(name)
      unless attribute?(name)
        raise ArgumentError, "invalid attribute #{name.inspect}"
      end

      @attributes[name.intern]
    end

    # @return [String] a human-readable representation of the entity, composed
    #   of the class name and the attribute keys and values.
    def inspect # rubocop:disable Metrics/AbcSize
      buffer = +'#<'
      buffer << self.class.name
      each_attribute.with_index do |(name, _metadata), index|
        buffer << ',' unless index.zero?
        buffer << ' ' << name.to_s << ': ' << get_attribute(name).inspect
      end
      buffer << '>'
    end

    # @param name [String] The name of the attribute.
    # @param value [Object] The new value of the attribute.
    #
    # @return [Object] the new value of the given attribute.
    #
    # @raise ArgumentError when the attribute name is not a valid attribute
    def set_attribute(name, value)
      unless attribute?(name)
        raise ArgumentError, "invalid attribute #{name.inspect}"
      end

      @attributes[name.intern] = value
    end

    private

    def each_attribute
      return enum_for(:each_attribute) unless block_given?

      self.class.each_attribute { |name, _metadata| yield(name) }
    end

    def initialize_attributes(data)
      @attributes = {}

      validate_attributes(data)

      self.class.each_attribute do |name, metadata|
        value = data[name] || data[name.intern] || metadata.default

        @attributes[name] = value
      end
    end

    def validate_attributes(obj)
      unless obj.is_a?(Hash)
        raise ArgumentError,
          "expected attributes to be a Hash, but was #{obj.inspect}"
      end

      obj.each_key do |name|
        unless attribute?(name)
          raise ArgumentError, "invalid attribute #{name.inspect}"
        end
      end
    end
  end
end
