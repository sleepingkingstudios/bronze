# lib/bronze/entities/associations/metadata/references_one_metadata.rb

require 'bronze/entities/associations/metadata/association_metadata'

module Bronze::Entities::Associations::Metadata
  # Class that characterizes a references one entity association.
  class ReferencesOneMetadata < AssociationMetadata
    # The type key for the association.
    ASSOCIATION_TYPE = :references_one

    # Required options for a references_one association.
    REQUIRED_KEYS = %i(foreign_key).freeze

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

    # (see AssociationMetadata#one)
    def one?
      true
    end # method one?

    # @return [Symbol] The name of tbe association predicate method.
    def predicate_name
      @predicate_name ||= :"#{association_name}?"
    end # method predicate_name

    private

    # rubocop:disable Metrics/MethodLength
    def expected_inverse_names
      expected_name = @inverse_name ||
                      (options.key?(:inverse) && options[:inverse])

      if expected_name
        if tools.string.plural?(expected_name.to_s)
          "has_many :#{expected_name}"
        else
          "has_one :#{expected_name}"
        end # if-elsif-else
      else
        "has_one :#{predict_inverse_name} or has_many " \
        ":#{predict_inverse_name :plural => true}"
      end # if-elsif-else
    end # method expected_inverse_names
    # rubocop:enable Metrics/MethodLength

    def expected_inverse_types
      inverse_classes = [
        Bronze::Entities::Associations::Metadata::HasManyMetadata,
        Bronze::Entities::Associations::Metadata::HasOneMetadata
      ] # end array

      inverse_classes.map { |klass| klass::ASSOCIATION_TYPE }
    end # method expected_inverse_types
  end # class
end # module
