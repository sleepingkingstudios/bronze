# lib/bronze/entities/attributes/dirty_tracking.rb

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/entities/attributes'

module Bronze::Entities::Attributes
  # Module for tracking changes in attribute values.
  module DirtyTracking
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    autoload :DirtyTrackingBuilder,
      'bronze/entities/attributes/dirty_tracking/dirty_tracking_builder'

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
        builder  =
          Bronze::Entities::Attributes::DirtyTracking::DirtyTrackingBuilder.
          new(self)

        builder.build(metadata)

        metadata
      end # method attribute

      private

      attr_accessor :attributes_dirty_tracking_module
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

      @attribute_changes[attr_name] = prior_value
    end # method track_attribute_changes_for_attribute
  end # module
end # module
