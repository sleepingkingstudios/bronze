# lib/patina/operations/entities/error_messages.rb

require 'patina/operations/entities'

module Patina::Operations::Entities
  # Common namespace for error message definitions.
  module ErrorMessages
    # Failure message when a resource fails validation.
    INVALID_RESOURCE = 'errors.operations.entities.invalid_resource'.freeze

    # Failure message when the record is already in the collection.
    RECORD_ALREADY_EXISTS =
      'errors.operations.entities.record_already_exists'.freeze

    # Failure message when the expected record is not found.
    RECORD_NOT_FOUND = 'errors.operations.entities.record_not_found'.freeze

    # Failure message when the record fails a uniqueness check.
    RECORD_NOT_UNIQUE = 'errors.operations.entities.record_not_unique'.freeze
  end # module
end # module
