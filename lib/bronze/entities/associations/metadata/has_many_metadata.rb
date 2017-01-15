# lib/bronze/entities/associations/metadata/has_many_metadata.rb

require 'bronze/entities/associations/metadata/association_metadata'

module Bronze::Entities::Associations::Metadata
  # Class that characterizes a has many entity association.
  class HasManyMetadata < AssociationMetadata
    # The type key for the association.
    ASSOCIATION_TYPE = :has_many

    # Required options for a has_many association.
    REQUIRED_KEYS = %i(inverse).freeze

    # @param entity_class [Class] The class of entity whose association is
    #   characterized by the metadata.
    # @param association_name [String, Symbol] The name of the association.
    # @param association_options [Hash] Additional options for the association.
    def initialize entity_class, association_name, association_options
      super(
        entity_class,
        ASSOCIATION_TYPE,
        association_name,
        association_options
      ) # end super
    end # method initialize

    # (see AssociationMetadata#many?)
    def many?
      true
    end # method many?
  end # class
end # module
