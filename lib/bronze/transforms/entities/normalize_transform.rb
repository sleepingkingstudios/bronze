# frozen_string_literal: true

require 'bronze/transform'
require 'bronze/transforms/entities'

module Bronze::Transforms::Entities
  # Transform class that maps an entity to a normal representation.
  class NormalizeTransform < Bronze::Transform
    # @param [Class] entity_class The entity class to normalize.
    # @param [Array<Class>] permit An optional array of types to normalize
    #   as-is, rather than applying a transform. Only default transforms can be
    #   permitted, i.e. the built-in default transforms for BigDecimal, Date,
    #   DateTime, Symbol, and Time, or for an attribute with the
    #   :default_transform flag set to true.
    def initialize(entity_class, permit: [])
      @entity_class    = entity_class
      @permitted_types = permit
    end

    # @return [Class] the entity class to normalize.
    attr_reader :entity_class

    # @return [Array<Class>] array of types to normalize as-is.
    attr_reader :permitted_types

    # Returns an entity instance.
    #
    # @param attributes [Hash] The normal representation of an entity.
    #
    # @return [Bronze::Entity] the entity instance.
    #
    # @see [Bronze::Entities::Normalization::denormalize]
    def denormalize(attributes)
      return nil if attributes.nil?

      entity_class.denormalize(attributes)
    end

    # Returns a normalized representation of the entity.
    #
    # @param entity [Bronze::Entity] The entity to normalize.
    #
    # @return [Hash] the normal representation.
    #
    # @see [Bronze::Entities::Normalization#normalize]
    def normalize(entity)
      return nil if entity.nil?

      entity.normalize(permit: permitted_types)
    end
  end
end
