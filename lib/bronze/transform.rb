# frozen_string_literal: true

require 'bronze/not_implemented_error'
require 'bronze/transforms'

module Bronze
  # Abstract class for converting an object to and from a normalized form. This
  # can be a hash for database serialization, an active model object, another
  # object, or any other transformation.
  class Transform
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
