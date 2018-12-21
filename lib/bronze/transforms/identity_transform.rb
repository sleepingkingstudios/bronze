# frozen_string_literal: true

require 'bronze/transform'

module Bronze::Transforms
  # Transform class that maps an object to itself.
  class IdentityTransform < Bronze::Transform
    # @return [IdentityTransform] a memoized instance of IdentityTransform.
    def self.instance
      @instance ||= new
    end

    # Returns the object that was passed in to the method.
    #
    # @param object [Object] The object to denormalize.
    #
    # @return [Object] the object passed in.
    def denormalize(object)
      object
    end

    # Returns the object that was passed in to the method.
    #
    # @param object [Object] The object to normalize.
    #
    # @return [Object] the object passed in.
    def normalize(object)
      object
    end
  end
end
