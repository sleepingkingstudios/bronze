# lib/bronze/transforms/transform.rb

require 'bronze/transforms'

module Bronze::Transforms
  # Abstract class for converting an object to and from a normalized form. This
  # can be a hash for database serialization, an active model object, another
  # object, or any other transformation.
  class Transform
    # Error class for handling unimplemented abstract transform methods.
    # Subclasses of Transform must implement these methods.
    class NotImplementedError < StandardError; end

    # Creates a transform chain with the current transform followed by the given
    # transform.
    #
    # @param transform [Bronze::Transforms::Transform]
    #
    # @return [Bronze::Transforms::TransformChain]
    def chain transform
      TransformChain.new(self, transform)
    end # method chain

    # Converts an object from its normalized form.
    #
    # @param _object [Object] The object to convert.
    #
    # @return [Object] The converted object.
    #
    # @see #entity_class.
    def denormalize _object
      raise NotImplementedError,
        "#{self.class.name} does not implement :denormalize",
        caller
    end # method denormalize

    # Converts an object to its normalized form.
    #
    # @param _object [Object] The entity to convert.
    #
    # @return [Object] The converted object.
    def normalize _object
      raise NotImplementedError,
        "#{self.class.name} does not implement :normalize",
        caller
    end # method normalize
  end # class
end # module
