# frozen_string_literal: true

require 'bronze/transform'
require 'bronze/transforms'

module Bronze::Transforms
  # Transform class that recursively copies a data object.
  class CopyTransform < Bronze::Transform
    # @return [CopyTransform] a memoized instance of IdentityTransform.
    def self.instance
      @instance ||= new
    end

    # Returns a deep copy of the object that was passed in to the method.
    #
    # @param object [Hash] The data object to denormalize.
    #
    # @return [Hash] the copied data object.
    def denormalize(object)
      return nil if object.nil?

      tools.hash.deep_dup(object)
    end

    # Returns a deep copy of the object that was passed in to the method.
    #
    # @param object [Hash] The data object to denormalize.
    #
    # @return [Hash] the copied data object.
    def normalize(object)
      return nil if object.nil?

      tools.hash.deep_dup(object)
    end

    private

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
