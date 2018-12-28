# lib/bronze/transforms/transform_chain.rb

require 'bronze/transform'
require 'bronze/transforms'

module Bronze::Transforms
  # Collection object that encapsulates a sequence of Transform objects and
  # implements the Transform interface.
  class TransformChain < Bronze::Transform
    # @param transforms [Array<Bronze::Transform>] The ordered sequence of
    #   transforms.
    def initialize *transforms
      @transforms = transforms
      @reversed   = transforms.reverse
    end # constructor

    # @return [Array<Bronze::Transform>] The ordered sequence of transforms.
    attr_reader :transforms

    # Appends the transform to the sequence of transforms.
    #
    # @param transform [Bronze::Transform]
    #
    # @return [Bronze::Transforms::TransformChain]
    def chain transform
      @transforms << transform
      @reversed = transforms.reverse

      self
    end # method chain

    # Calls #denormalize on each transform in reversed sequence, passing the
    # object to the first transform and the result to each subsequent transform.
    #
    # (see Bronze::Transform#denormalize)
    def denormalize object
      reversed.reduce(object) { |memo, transform| transform.denormalize(memo) }
    end # method denormalize

    # Calls #normalize on each transform in sequence, passing the object to the
    # first transform and the result to each subsequent transform.
    #
    # (see Bronze::Transforms#normalize)
    def normalize object
      transforms.reduce(object) { |memo, transform| transform.normalize(memo) }
    end # method normalize

    private

    attr_reader :reversed
  end # class
end # module
