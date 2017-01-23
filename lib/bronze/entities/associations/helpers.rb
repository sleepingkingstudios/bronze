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

      def validate_association!(
        metadata,
        value,
        allow_nil:         true,
        allow_primary_key: false
      ) # end params
        return if allow_nil && value.nil?

        return if allow_primary_key &&
                  value.is_a?(metadata.association_class::KEY_TYPE)

        return if value.is_a?(metadata.association_class)

        tools = ::SleepingKingStudios::Tools::StringTools
        name  = tools.singularize(metadata.name.to_s)

        raise ArgumentError,
          "#{name} must be a #{metadata.association_class}",
          caller[1..-1]
      end # method validate_association!

      # rubocop:disable Metrics/MethodLength
      def validate_collection! metadata, collection
        return if collection.nil?

        if collection.is_a?(Array) ||
           collection.is_a?(Bronze::Entities::Associations::Collection)

          return if collection.empty?

          collection.each do |item|
            validate_association!(metadata, item, :allow_nil => false)
          end # each

          return
        end # if

        raise ArgumentError,
          "#{metadata.name} must be a collection of "\
          "#{metadata.association_class.name} entities",
          caller[1..-1]
      end # method validate_collection!
      # rubocop:enable Metrics/MethodLength
    end # module
  end # module
end # module
