# lib/bronze/entities/transforms/copy_transform.rb

require 'bronze/entities/transforms/transform'

module Bronze::Entities::Transforms
  # Copies the object when denormalizing the object from the datastore.
  class CopyTransform < Bronze::Entities::Transforms::Transform
    def initialize
      super(nil)
    end # constructor

    # Performs a deep copy on the object. This prevents scopes that receive the
    # object from changing the datastore by manipulating the received object.
    #
    # @param object [Object] The object to denormalize.
    #
    # @return [Object] The copied object.
    def denormalize object
      tools = ::SleepingKingStudios::Tools::ObjectTools

      tools.deep_dup(object)
    end # method denormalize

    # Performs a deep copy on the object. This prevents later scopes from
    # changing the datastore by manipulating the received object.
    #
    # @param object [Object] The object to denormalize.
    #
    # @return [Object] The copied object.
    def normalize object
      tools = ::SleepingKingStudios::Tools::ObjectTools

      tools.deep_dup(object)
    end # method normalize
  end # class
end # module
