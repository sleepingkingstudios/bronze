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
      private

      attr_accessor :attributes_dirty_tracking_module

      def build_attribute *args
        metadata = super

        builder  =
          Bronze::Entities::Attributes::DirtyTracking::DirtyTrackingBuilder.
          new(self)

        builder.build(metadata)

        metadata
      end # method build_attribute
    end # module

    # @param attributes [Hash] The default attributes with which to initialize
    #   the entity. Defaults to an empty hash.
    def initialize _attributes = {}
      @attribute_changes = {}

      super

      clean_attributes
    end # constructor

    # @return [Boolean] True if any of the entity's attributes have been changed
    #   since the entity was last cleaned; otherwise false.
    def attributes_changed?
      !@attribute_changes.empty?
    end # method attributes_changed?

    # Marks the entity's attributes as clean, i.e. unchanged from the last point
    # of reference (typically a persistence event, such as loading from or
    # saving to a datastore).
    def clean_attributes
      @attribute_changes = {}
    end # method clean_attributes

    private

    def track_attribute_changes_for_attribute metadata, new_value
      attr_name   = metadata.attribute_name
      prior_value = send(metadata.reader_name)

      return if prior_value == new_value

      @attribute_changes[attr_name] = prior_value
    end # method track_attribute_changes_for_attribute
  end # module
end # module
