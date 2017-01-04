# lib/bronze/entities/associations.rb

require 'bronze/entities'

module Bronze::Entities
  # Namespace for library classes and modules that build and characterize
  # entity associations.
  module Associations
    # @param attributes [Hash] The default attributes with which to initialize
    #   the entity. Defaults to an empty hash.
    def initialize attributes = {}
      @associations = {}

      super
    end # constructor
  end # module
end # module
