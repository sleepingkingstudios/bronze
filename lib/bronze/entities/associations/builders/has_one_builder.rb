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
      metadata = mt_class.new(entity_class, name, options)

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

    def define_writer metadata
      entity_class_associations.send :define_method,
        metadata.writer_name,
        ->(entity) { write_has_one_association(metadata, entity) }
    end # method define_writer

    def options_with_inverse_name options
      return options if options.key?(:inverse)

      return options if entity_class.name.nil?

      options.update(:inverse => entity_class.name.split('::').last)
    end # method options_with_foreign_key
  end # class
end # module
