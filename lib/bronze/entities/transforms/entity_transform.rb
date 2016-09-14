# lib/bronze/entities/transforms/entity_transform.rb

require 'bronze/entities/transforms'
require 'bronze/transforms/transform'

module Bronze::Entities::Transforms
  # Maps an entity to a data hash using the entity's defined attributes.
  class EntityTransform < Bronze::Transforms::Transform
    # @param entity_class [Class] The class into which data hashes will be
    #   denormalized.
    def initialize entity_class
      @entity_class = entity_class
    end # constructor

    # @return [Class] The class into which data hashes will be denormalized.
    attr_reader :entity_class

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
      return entity_class.new if attributes.nil?

      entity = entity_class.new

      entity_class.attributes.each do |attr_name, _|
        entity.send(:"#{attr_name}=", attributes[attr_name])
      end # each

      entity
    end # method denormalize

    # Converts the entity into a data hash, with the keys being the defined
    # attributes for the entity.
    #
    # @param entity [Bronze::Entities::Entity] The entity to convert.
    #
    # @return [Hash] The converted data hash.
    def normalize entity
      return {} if entity.nil?

      hsh = {}

      entity_class.attributes.each do |attr_name, _|
        hsh[attr_name] = entity.send(attr_name)
      end # each

      hsh
    end # method normalize
  end # class
end # module
