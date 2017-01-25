# lib/bronze/entities/transforms/entity_transform.rb

require 'bronze/entities/transforms'
require 'bronze/transforms/transform'

module Bronze::Entities::Transforms
  # Maps an entity to a data hash using the entity's defined attributes.
  class EntityTransform < Bronze::Transforms::Transform
    # @param entity_class [Class] The class into which data hashes will be
    #   denormalized.
    # @param options [Hash] Configuration options that will be passed to
    #   #normalize and #denormalize.
    def initialize entity_class, **options
      @entity_class = entity_class
      @options      = options
    end # constructor

    # @return [Class] The class into which data hashes will be denormalized.
    attr_reader :entity_class

    # return [Hash] Configuration options that will be passed to #normalize and
    #   #denormalize.
    attr_reader :options

    # Converts a data hash into an entity instance and sets the value of the
    # entity attribute to the values of the hash for each attribute defined by
    # the entity class.
    #
    # @param attributes [Hash] The hash to convert.
    #
    # @return [Bronze::Entities::Entity] The converted entity.
    #
    # @see #entity_class.
    def denormalize attributes
      entity_class.denormalize(attributes || {}, options)
    end # method denormalize

    # Converts the entity into a data hash, with the keys being the defined
    # attributes for the entity.
    #
    # @param entity [Bronze::Entities::Entity] The entity to convert.
    #
    # @return [Hash] The converted data hash.
    def normalize entity
      return {} if entity.nil?

      entity.normalize(options)
    end # method normalize
  end # class
end # module
