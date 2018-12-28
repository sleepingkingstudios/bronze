# frozen_string_literal: true

require 'bronze'

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
      raise NotImplementedError,
        "#{self.class.name} does not implement :denormalize"
    end

    # Converts an object to its normalized form.
    #
    # @param _object [Object] The entity to convert.
    #
    # @return [Object] The converted object.
    def normalize(_object)
      raise NotImplementedError,
        "#{self.class.name} does not implement :normalize"
    end
  end
end
