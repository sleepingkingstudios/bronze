# lib/bronze/entities/associations/metadata/references_one_metadata.rb

require 'bronze/entities/associations/metadata/association_metadata'

module Bronze::Entities::Associations::Metadata
  # Class that characterizes a references one entity association.
  class ReferencesOneMetadata < AssociationMetadata
    # The type key for the association.
    ASSOCIATION_TYPE = :references_one

    # Required options for a references_one association.
    REQUIRED_KEYS = %i(foreign_key).freeze

    # @param association_name [String, Symbol] The name of the association.
    # @param association_options [Hash] Additional options for the association.
    def initialize association_name, association_options
      super(ASSOCIATION_TYPE, association_name, association_options)
    end # method initialize

    # (see AssociationMetadata#one)
    def one?
      true
    end # method one?

    # @return [Symbol] The name of tbe association predicate method.
    def predicate_name
      @predicate_name ||= :"#{association_name}?"
    end # method predicate_name
  end # class
end # module
