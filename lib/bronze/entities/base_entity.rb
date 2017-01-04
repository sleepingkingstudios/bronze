# lib/bronze/entities/base_entity.rb

require 'bronze/entities'

module Bronze::Entities
  # Superclass to catch unhandled initialization parameters.
  class BaseEntity
    def initialize _attributes = {}
      # Unhandled initialization parameters are ignored.
    end # constructor
  end # class
end # module
