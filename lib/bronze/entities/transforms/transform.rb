# lib/bronze/entities/transforms/transform.rb

require 'bronze/entities/transforms'

module Bronze::Entities::Transforms
  # Abstract class for converting an entity to and from a normalized form. This
  # can be a hash for database serialization, an active model object, another
  # entity, or any other transformation.
  class Transform
    # Error class for handling unimplemented abstract transform methods.
    # Subclasses of Transform must implement these methods.
    class NotImplementedError < StandardError; end

    # @param entity_class [Class] The class into which data hashes will be
    #   denormalized.
    def initialize entity_class
      @entity_class = entity_class
    end # constructor

    # @return [Class] The class into which data hashes will be denormalized.
    attr_reader :entity_class

    # Converts an object into an entity instance. The entity type is defined by
    # the #entity_class method.
    #
    # @param _object [Object] The object to convert.
    #
    # @return [Bronze::Entities::Entity] The converted entity.
    #
    # @see #entity_class.
    def denormalize _object
      raise NotImplementedError,
        "#{self.class.name} does not implement :denormalize",
        caller
    end # method denormalize

    # Converts the entity into another object.
    #
    # @param _entity [Bronze::Entities::Entity] The entity to convert.
    #
    # @return [Object] The converted object.
    def normalize _entity
      raise NotImplementedError,
        "#{self.class.name} does not implement :normalize",
        caller
    end # method normalize
  end # class
end # module
