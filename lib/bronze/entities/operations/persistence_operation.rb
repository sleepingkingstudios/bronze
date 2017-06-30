# lib/bronze/entities/operations/persistence_operation.rb

require 'bronze/entities/transforms/entity_transform'

module Bronze::Entities::Operations
  # Abstract operation class for entity operations that act on a repository,
  # such as reading or writing data or checking for the existence of an entity
  # within the repository.
  module PersistenceOperation
    # @param entity_class [Class] The class of entity this operation acts upon.
    # @param repository [Bronze::Collections::Repository] The data repository to
    #   access or reference.
    def initialize entity_class, repository
      super(entity_class)

      @repository = repository
    end # constructor

    # @return [Bronze::Collections::Repository] The data repository.
    attr_reader :repository

    # @return [Bronze::Collections::Collection] The data collection for the
    #   entity class.
    def collection
      @collection ||= repository.collection(entity_class, transform)
    end # method collection

    private

    def transform
      Bronze::Entities::Transforms::EntityTransform.new(entity_class)
    end # method transform
  end # class
end # module
