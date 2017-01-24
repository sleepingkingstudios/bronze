# lib/bronze/entities/normalization.rb

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
      # @return [Bronze::Entities::Entity] The entity.
      def denormalize hsh
        entity = new

        attributes.each do |attr_name, metadata|
          entity.send(metadata.writer_name, hsh[attr_name])
        end # each

        entity
      end # method denormalize
    end # module

    # Returns a normalized representation of the entity. The normal
    # representation of an entity is a hash with String keys. Each value must be
    # nil, a literal value (true, false, a String, an Integer, a Float, etc), an
    # Array of normal values, or a Hash with String keys and normal values.
    #
    # @return [Hash] The normal representation.
    def normalize
      hsh = {}

      self.class.attributes.each do |attr_name, metadata|
        hsh[attr_name] = send(metadata.reader_name)
      end # each

      hsh
    end # method normalize
  end # module
end # module
