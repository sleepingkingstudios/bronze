# lib/bronze/entities/attributes/dirty_tracking/dirty_tracking_builder.rb

require 'bronze/entities/attributes/dirty_tracking'

module Bronze::Entities::Attributes::DirtyTracking
  # Service class to define attribute change tracking on an entity.
  class DirtyTrackingBuilder
    # @param entity_class [Class] The entity class on which attributes will be
    #   defined.
    def initialize entity_class
      @entity_class = entity_class
    end # constructor

    # @return [Class] The entity class on which attributes will be defined.
    attr_reader :entity_class

    # Adds attribute change tracking to the entity class for the given
    # attribute.
    #
    # @param metadata [Attributes::AttributeMetadata] The metadata for the
    #   attribute to track.
    def build metadata
      define_attribute_change_tracking_methods(metadata)
    end # method build

    private

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
  end # class
end # module
