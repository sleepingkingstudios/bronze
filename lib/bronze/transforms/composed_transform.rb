# frozen_string_literal: true

require 'bronze/transform'
require 'bronze/transforms'

module Bronze::Transforms
  # A transform that composes two other transform instances as a pipeline.
  class ComposedTransform < Bronze::Transform
    # @param left_transform [Bronze::Transform] The left transform - called
    #   first in #normalize and last in #denormalize.
    # @param right_transform [Bronze::Transform] The right transform - called
    #   last in #normalize and first in #denormalize.
    def initialize(left_transform, right_transform)
      @left_transform  = left_transform
      @right_transform = right_transform
    end

    # Evaluates the transforms' #denormalize methods from right to left.
    #
    # @param object [Object] The object to convert.
    #
    # @return [Object] The converted object.
    def denormalize(value)
      @left_transform.denormalize(@right_transform.denormalize(value))
    end

    # Evaluates the transforms' #normalize methods from left to right.
    #
    # @param object [Object] The object to convert.
    #
    # @return [Object] The converted object.
    def normalize(value)
      @right_transform.normalize(@left_transform.normalize(value))
    end
  end
end
