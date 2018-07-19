require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/entities/operations/entity_operation'
require 'bronze/entities/transforms/entity_transform'

module Bronze::Entities::Operations
  # Abstract operation class for entity operations that act on a repository,
  # such as reading or writing data or checking for the existence of an entity
  # within the repository.
  module PersistenceOperation
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    include Bronze::Entities::Operations::EntityOperation

    # @param entity_class [Class] The class of entity this operation acts upon.
    # @param repository [Bronze::Collections::Repository] The data repository to
    #   access or reference.
    # @param transform [Bronze::Transforms::Transform] The transform used to
    #   serialize and deserialize entities to and from the repository.
    def initialize(*args, repository:, transform: nil, **kwargs)
      # RUBY_VERSION: Required below 2.5
      args << kwargs unless kwargs.empty?

      super(*args)

      @repository = repository
      @transform  = transform
    end

    # @return [Bronze::Collections::Repository] The data repository.
    attr_reader :repository

    # @return [Bronze::Collections::Collection] The data collection for the
    #   entity class.
    def collection
      @collection ||= repository.collection(entity_class, transform)
    end

    # @return [Bronze::Transforms::Transform] The transform used to serialize
    #   and deserialize entities to and from the repository. Defaults to an
    #   instance of Bronze::Entities::Transforms::EntityTransform.
    def transform
      @transform ||= default_transform
    end

    private

    def default_transform
      Bronze::Entities::Transforms::EntityTransform.new(entity_class)
    end

    def persist_entity entity
      return entity unless entity.respond_to?(:persist)

      entity.tap(&:persist)
    end
  end
end
