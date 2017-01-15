# lib/bronze/entities/associations/builders/references_one_builder.rb

require 'bronze/entities/associations/builders/association_builder'
require 'bronze/entities/associations/metadata/references_one_metadata'

module Bronze::Entities::Associations::Builders
  # Service class to define references_one associations on an entity.
  class ReferencesOneBuilder < AssociationBuilder
    # Defines a references_one association on the entity class.
    def build assoc_name, assoc_options = {}
      name = tools.string.singularize(assoc_name.to_s)

      options = tools.hash.symbolize_keys(assoc_options)
      options = options_with_class_name(options, name)
      options = options_with_foreign_key(options, name)

      mt_class = Bronze::Entities::Associations::Metadata::ReferencesOneMetadata
      metadata = mt_class.new(entity_class, name, options)

      define_property_methods(metadata)

      metadata
    end # method build

    private

    def define_foreign_key metadata
      entity_class.foreign_key(metadata.foreign_key)
    end # method define_foreign_key

    def define_predicate metadata
      assoc_name = metadata.association_name

      entity_class_associations.send :define_method,
        metadata.predicate_name,
        ->() { !@associations[assoc_name].nil? }
    end # method define_predicate

    def define_property_methods metadata
      define_foreign_key(metadata)
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
        ->(entity) { write_references_one_association(metadata, entity) }
    end # method define_writer

    def options_with_foreign_key options, name
      return options if options.key?(:foreign_key)

      options.update(:foreign_key => :"#{name}_id")
    end # method options_with_foreign_key
  end # class
end # module
