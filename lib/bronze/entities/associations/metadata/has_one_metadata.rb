# lib/bronze/entities/associations/metadata/has_one_metadata.rb

require 'bronze/entities/associations/metadata/association_metadata'

module Bronze::Entities::Associations::Metadata
  # Class that characterizes a has one entity association.
  class HasOneMetadata < AssociationMetadata
    # The type key for the association.
    ASSOCIATION_TYPE = :has_one

    # Required options for a has_one association.
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

    # (see AssociationMetadata#one?)
    def one?
      true
    end # method one?

    # @return [Symbol] The name of tbe association predicate method.
    def predicate_name
      @predicate_name ||= :"#{association_name}?"
    end # method predicate_name
  end # class
end # module
