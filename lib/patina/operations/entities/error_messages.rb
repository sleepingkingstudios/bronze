# lib/patina/operations/entities/error_messages.rb

require 'patina/operations/entities'

module Patina::Operations::Entities
  # Common namespace for error message definitions.
  module ErrorMessages
    # Failure message when the expected record is not found.
    RECORD_NOT_FOUND = 'operations.entities.record_not_found'.freeze
  end # module
end # module
