# frozen_string_literal: true

require 'bronze'
require 'bronze/not_implemented_error'

module Bronze
  # Abstract class for converting an object to and from a normalized form. This
  # can be a hash for database serialization, an active model object, another
  # object, or any other transformation.
  class Transform
    # Left or "backward" composes the transform with the given other transform.
    #
    # The given transform will be applied first in a #normalize call (and vice
    # versa in a #denormalize call).
    #
    # When calling #denormalize, the value will be passed to this transform's
    # #denormalize method. The result is then passed to the second transform's
    # #denormalize method, and that result is returned.
    #
    # When calling #normalize, the value will be passed to the second
    # transform's #normalize method. The result is then passed to the this
    # transform's #normalize method, and that result is returned.
    #
    # @param other [Bronze::Transform] The other transform to compose.
    #
    # @see #<<
    def <<(other)
      Bronze::Transforms::ComposedTransform.new(other, self)
    end

    # Right or "forward" composes the transform with the given other transform.
    #
    # This is equivalent to a pipeline operation, e.g. this transform will be
    # applied first in a #normalize call (and vice versa in a #denormalize
    # call).
    #
    # When calling #denormalize, the value will be passed to the second
    # transform's #denormalize method. The result is then passed to the this
    # transform's #denormalize method, and that result is returned.
    #
    # When calling #normalize, the value will be passed to this transform's
    # #normalize method. The result is then passed to the second transform's
    # #normalize method, and that result is returned.
    #
    # @param other [Bronze::Transform] The other transform to compose.
    #
    # @see #<<
    def >>(other)
      Bronze::Transforms::ComposedTransform.new(self, other)
    end

    # Converts an object from its normalized form.
    #
    # @param _object [Object] The object to convert.
    #
    # @return [Object] The converted object.
    def denormalize(_object)
      raise Bronze::NotImplementedError.new(self, :denormalize)
    end

    # Converts an object to its normalized form.
    #
    # @param _object [Object] The entity to convert.
    #
    # @return [Object] The converted object.
    def normalize(_object)
      raise Bronze::NotImplementedError.new(self, :normalize)
    end
  end
end

require 'bronze/transforms/composed_transform'
