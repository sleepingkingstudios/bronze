# lib/bronze/entities/attributes/dirty_tracking.rb

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/entities/attributes'

module Bronze::Entities::Attributes
  # Module for tracking changes in attribute values.
  module DirtyTracking
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    # Class methods to define when including Attributes::DirtyTracking in a
    # class.
    module ClassMethods
      # Adds dirty tracking to the specified attribute.
      #
      # @param (see Attributes::attribute)
      #
      # @option (see Attributes::attribute)
      #
      # @return (see Attributes::attribute)
      #
      # @raise (see Attributes::attribute)
      def attribute *args
        metadata = super

        define_attribute_change_tracking_methods(metadata)

        metadata
      end # method attribute

      private

      attr_accessor :attributes_dirty_tracking_module

      def define_attribute_change_tracking_methods metadata
        wrap_writer_with_change_tracking(metadata)

        define_attribute_changed_predicate(metadata)
      end # method define_attribute_change_tracking_methods

      def define_attribute_changed_predicate metadata
        attr_name = metadata.attribute_name

        entity_class_attribute_dirty_tracking.send :define_method,
          :"#{attr_name}_changed?",
          lambda {
            @attribute_changes.key? attr_name
          } # end lambda
      end # method define_attribute_changed_predicate

      # rubocop:disable Metrics/MethodLength
      def entity_class_attribute_dirty_tracking
        entity_class = self

        @entity_class_attribute_dirty_tracking ||=
          begin
            unless entity_class.send(:attributes_dirty_tracking_module)
              mod =
                entity_class.send(
                  :attributes_dirty_tracking_module=,
                  Module.new
                ) # end module

              entity_class.const_set(:AttributesDirtyTrackingMethods, mod)

              entity_class.include entity_class::AttributesDirtyTrackingMethods
            end # unless

            entity_class::AttributesDirtyTrackingMethods
          end # begin
      end # method entity_class_attribute_dirty_tracking
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      def wrap_writer_with_change_tracking metadata
        entity_class_attribute_dirty_tracking.send :define_method,
          metadata.writer_name,
          lambda { |value|
            track_attribute_changes_for_attribute(metadata, value)

            super(value)
          } # end lambda

        return unless metadata.read_only?

        entity_class_attribute_dirty_tracking.send(
          :private,
          metadata.writer_name
        ) # end send
      end # wrap_writer_with_change_tracking
      # rubocop:enable Metrics/MethodLength
    end # module

    # @param attributes [Hash] The default attributes with which to initialize
    #   the entity. Defaults to an empty hash.
    def initialize _attributes = {}
      @attribute_changes = {}

      super

      clean_attribute_changes
    end # constructor

    # @return [Boolean] True if any of the entity's attributes have been changed
    #   since the entity was last cleaned; otherwise false.
    def attributes_changed?
      !@attribute_changes.empty?
    end # method attributes_changed?

    private

    def clean_attribute_changes
      @attribute_changes = {}
    end # method clean_attribute_changes

    def track_attribute_changes_for_attribute metadata, new_value
      attr_name   = metadata.attribute_name
      prior_value = send(metadata.reader_name)

      return if prior_value == new_value

      @attribute_changes[attr_name] = new_value
    end # method track_attribute_changes_for_attribute
  end # module
end # module
