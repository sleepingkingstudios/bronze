# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/entities'

module Bronze::Entities
  # Module for transforming entities to and from a normal form.
  module Normalization
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    # Class methods to define when including Normalization in a class.
    module ClassMethods
      # Returns an entity instance from the given normalized representation.
      #
      # @param attributes [Hash] A hash with String keys and normal values.
      #
      # @return [Bronze::Entity] The entity.
      def denormalize(attributes)
        entity = new

        entity.send(:validate_attributes, attributes)

        each_attribute do |name, metadata|
          value = attributes[name] || attributes[name.to_s]
          value = metadata.transform.denormalize(value) if metadata.transform?

          next if value.nil? && metadata.primary_key?

          entity.set_attribute(name, value)
        end

        entity
      end
    end

    # Returns a normalized representation of the entity. The normal
    # representation of an entity is a hash with String keys. Each value must be
    # nil, a literal value (true, false, a String, an Integer, a Float, etc), an
    # Array of normal values, or a Hash with String keys and normal values.
    #
    # @return [Hash] The normal representation.
    def normalize
      self.class.each_attribute.with_object({}) do |(name, metadata), hsh|
        value = get_attribute(name)
        value = metadata.transform.normalize(value) if metadata.transform?

        hsh[name.to_s] = value
      end
    end
  end
end
