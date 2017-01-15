# lib/bronze/entities/associations/helpers.rb

require 'bronze/entities'

module Bronze::Entities
  module Associations
    # Helper methods for reading and writing associations across entity classes.
    module Helpers
      protected

      def get_association metadata
        @associations[metadata.name]
      end # method set_association

      def set_association metadata, value
        @associations[metadata.name] = value
      end # method set_association

      def set_foreign_key metadata, value
        send(metadata.foreign_key_writer_name, value)
      end # method set_foreign_key

      private

      def validate_association! metadata, value, allow_nil: true
        return if allow_nil && value.nil?

        return if value.is_a?(metadata.association_class)

        raise ArgumentError,
          "#{metadata.name} must be a #{metadata.association_class}",
          caller[1..-1]
      end # method validate_association!
    end # module
  end # module
end # module
