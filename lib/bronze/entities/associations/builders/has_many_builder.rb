# lib/bronze/entities/associations/builders/has_many_builder.rb

require 'bronze/entities/associations/builders/association_builder'
require 'bronze/entities/associations/collection'

module Bronze::Entities::Associations::Builders
  # Service class to define has_many associations on an entity.
  class HasManyBuilder < AssociationBuilder
    # Defines a has_one association on the entity class.
    def build assoc_name, assoc_options = {}
      name = tools.string.pluralize(assoc_name.to_s)

      options = tools.hash.symbolize_keys(assoc_options)
      options = options_with_class_name(options, name)
      options = options_with_inverse_name(options)

      mt_class = Bronze::Entities::Associations::Metadata::HasManyMetadata
      metadata = mt_class.new(entity_class, name, options)

      define_property_methods(metadata)

      metadata
    end # method build

    private

    def define_property_methods metadata
      define_reader(metadata)
      define_writer(metadata)
    end # method define_property_methods

    def define_reader metadata
      assoc_name = metadata.association_name
      default    = lambda do |entity|
        Bronze::Entities::Associations::Collection.new(entity, metadata)
      end # lambda

      entity_class_associations.send :define_method,
        metadata.reader_name,
        ->() { (@associations[assoc_name] ||= default.call(self)) }
    end # method define_reader

    def define_writer metadata
      entity_class_associations.send :define_method,
        metadata.writer_name,
        ->(entities) { write_has_many_association(metadata, entities) }
    end # method define_writer

    def options_with_inverse_name options
      return options if options.key?(:inverse)

      return options if entity_class.name.nil?

      options.update(:inverse => entity_class.name.split('::').last)
    end # method options_with_foreign_key
  end # class
end # module
