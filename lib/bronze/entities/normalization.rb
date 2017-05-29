# lib/bronze/entities/normalization.rb

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/entities'

module Bronze::Entities
  # Module for transforming entities to and from a normal form.
  module Normalization
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    # Class methods to define when including Normalization in a class.
    module ClassMethods
      # rubocop:disable Lint/UnusedMethodArgument

      # Returns an entity instance from the given normalized representation.
      #
      # @return [Bronze::Entities::Entity] The entity.
      def denormalize hsh, permit: nil
        attrs = {}

        hsh.each do |key, value|
          metadata = attributes[key]

          next unless metadata

          attrs[key] = metadata.attribute_type.denormalize(value)
        end # each

        new(attrs)
      end # method denormalize

      # rubocop:enable Lint/UnusedMethodArgument
    end # module

    # Returns a normalized representation of the entity. The normal
    # representation of an entity is a hash with String keys. Each value must be
    # nil, a literal value (true, false, a String, an Integer, a Float, etc), an
    # Array of normal values, or a Hash with String keys and normal values.
    #
    # @return [Hash] The normal representation.
    def normalize permit: nil
      hsh       = {}
      permitted = Array(permit).compact

      self.class.attributes.each do |attr_name, metadata|
        value = send(metadata.reader_name)

        unless permitted.include?(metadata.object_type)
          value = metadata.attribute_type.normalize(value)
        end # unless

        hsh[attr_name] = value
      end # each

      hsh
    end # method normalize
  end # module
end # module
