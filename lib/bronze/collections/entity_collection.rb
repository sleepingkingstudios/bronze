# frozen_string_literal: true

require 'bronze/collection'
require 'bronze/collections'
require 'bronze/entity'
require 'bronze/transforms/entities/normalize_transform'

module Bronze::Collections
  # An entity collection represents a data set as a collection of entity
  # objects, providing additional validation and natively wrapping entities as
  # the parameters and returned values of collection operations.
  class EntityCollection < Bronze::Collection
    def initialize(definition, adapter:, name: nil, transform: nil)
      parse_entity_class(definition)

      options = {
        adapter:   adapter,
        name:      name,
        transform: transform || build_transform
      }

      options[:primary_key] = false unless entity_class_has_primary_key?

      super(definition, **options)
    end

    attr_reader :entity_class

    private

    def build_transform
      Bronze::Transforms::Entities::NormalizeTransform.new(entity_class)
    end

    def entity_class_has_primary_key?
      return false unless entity_class.respond_to?(:primary_key)

      !entity_class.primary_key.nil?
    end

    def parse_entity_class(definition)
      require_entity_class!(definition)

      @entity_class = definition
    end

    def require_entity_class!(definition)
      return if definition.is_a?(Class) && definition < Bronze::Entity

      raise ArgumentError,
        'expected definition to be an entity class, but was ' \
        "#{definition.inspect}"
    end
  end
end
