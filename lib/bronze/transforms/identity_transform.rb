# lib/bronze/transforms/identity_transform.rb

require 'bronze/transforms/transform'

module Bronze::Transforms
  # Maps an object to itself.
  class IdentityTransform < Transform
    # Returns the object that was passed in to the method.
    #
    # @param object [Object] The object to denormalize.
    #
    # @return [Object] The object passed in.
    def denormalize object
      object
    end # method denormalize

    # Returns the object that was passed in to the method.
    #
    # @param object [Object] The object to normalize.
    #
    # @return [Object] The object passed in.
    def normalize object
      object
    end # method normalize
  end # class
end # module
