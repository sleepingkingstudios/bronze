# lib/bronze/entities/associations/builders/has_one_builder.rb

require 'bronze/entities/associations/builders/association_builder'
require 'bronze/entities/associations/metadata/has_one_metadata'

module Bronze::Entities::Associations::Builders
  # Service class to define has_one associations on an entity.
  class HasOneBuilder < AssociationBuilder
    # Defines a has_one association on the entity class.
    def build assoc_name, assoc_options = {}
      name = tools.string.singularize(assoc_name.to_s)

      options = tools.hash.symbolize_keys(assoc_options)
      options = options_with_class_name(options, name)
      options = options_with_inverse_name(options)

      mt_class = Bronze::Entities::Associations::Metadata::HasOneMetadata
      metadata = mt_class.new(name, options)

      define_property_methods(metadata)

      metadata
    end # method build

    private

    def define_predicate metadata
      assoc_name = metadata.association_name

      entity_class_associations.send :define_method,
        metadata.predicate_name,
        ->() { !@associations[assoc_name].nil? }
    end # method define_predicate

    def define_property_methods metadata
      define_predicate(metadata)
      define_reader(metadata)
      define_writer(metadata)
    end # method define_property_methods

    def define_reader metadata
      assoc_name = metadata.association_name

      entity_class_associations.send :define_method,
        metadata.reader_name,
        ->() { @associations[assoc_name] }
    end # method define_reader

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def define_writer metadata
      assoc_name = metadata.association_name

      entity_class_associations.send :define_method,
        metadata.writer_name,
        lambda { |entity|
          unless entity.nil? || entity.is_a?(metadata.association_class)
            raise ArgumentError,
              "#{assoc_name} must be a #{metadata.association_class}"
          end # unless

          inverse_metadata = metadata.inverse_metadata
          prior_value      = get_association(assoc_name)

          # If a prior value exists, we need to clear its inverse association.
          if prior_value
            prior_value.send(inverse_metadata.foreign_key_writer_name, nil)
            prior_value.set_association(inverse_metadata.name, nil)
          end # if

          # If the new value exists, we need to update its inverse association.
          if entity
            prior_inverse = entity.send(inverse_metadata.reader_name)

            # If the entity already had an inverse, we need to clear the
            # association on the inverse object.
            prior_inverse.set_association(assoc_name, nil) if prior_inverse

            # Next, we set the inverse association and foreign key.
            entity.send(inverse_metadata.foreign_key_writer_name, id)
            entity.set_association(inverse_metadata.name, self)
          end # if

          # Finally, we set the association to the new value.
          set_association(assoc_name, entity)
        } # end lambda
    end # method define_writer
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def options_with_inverse_name options
      return options if options.key?(:inverse)

      return options if entity_class.name.nil?

      options.update(:inverse => entity_class.name.split('::').last)
    end # method options_with_foreign_key
  end # class
end # module
