# lib/patina/collections/validation.rb

require 'patina/collections'

module Patina::Collections
  # Shared validation methods for collections to ensure a common interface when
  # error conditions are encountered.
  module Validation
    private

    def error_types
      Bronze::Collections::Collection::Errors
    end # method error_types

    def validate_attributes attributes
      return build_errors.add(error_types.data_missing) if attributes.nil?

      unless attributes.is_a?(Hash)
        return build_errors.add(
          error_types.data_invalid,
          :attributes => attributes
        ) # end errors
      end # unless

      []
    end # method validate_attributes

    def validate_id id
      if id.nil?
        return build_errors.add(error_types.primary_key_missing, :key => :id)
      end # if

      []
    end # method validate_id
  end # module
end # module
