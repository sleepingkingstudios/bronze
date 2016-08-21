# lib/bronze/entities/transforms/identity_transform.rb

require 'bronze/entities/transforms/transform'

module Bronze::Entities::Transforms
  # Maps an object to itself.
  class IdentityTransform < Transform
    def initialize
      super(nil)
    end # constructor

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
