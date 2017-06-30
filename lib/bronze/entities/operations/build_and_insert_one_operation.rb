# lib/bronze/entities/operations/build_and_insert_one_operation.rb

require 'bronze/entities/operations/build_one_operation'
require 'bronze/entities/operations/entity_operation'
require 'bronze/entities/operations/insert_one_without_validation_operation'
require 'bronze/entities/operations/persistence_operation'
require 'bronze/entities/operations/validate_one_operation'
require 'bronze/entities/operations/validate_one_uniqueness_operation'
require 'bronze/operations/operation_chain'

module Bronze::Entities::Operations
  # Operation for building a new entity with the contents of an attributes hash,
  # validating the entity and, if valid, inserting the entity into the
  # repository.
  class BuildAndInsertOneOperation < Bronze::Operations::OperationChain
    include Bronze::Entities::Operations::EntityOperation
    include Bronze::Entities::Operations::PersistenceOperation

    # @param entity_class [Class] The class of entity this operation acts upon.
    # @param repository [Bronze::Collections::Repository] The data repository to
    #   access or reference.
    def initialize entity_class, repository
      super

      @operations      = []
      @first_operation = build_operation(entity_class)

      self.
        then(validate_attributes_operation entity_class).
        then(validate_uniqueness_operation entity_class).
        then(insert_operation entity_class)
    end # constructor

    private

    def build_operation entity_class
      Bronze::Entities::Operations::BuildOneOperation.new(entity_class)
    end # method build_operation

    def insert_operation entity_class
      Bronze::Entities::Operations::InsertOneWithoutValidationOperation.
        new(entity_class, repository)
    end # method insert_operation

    def validate_attributes_operation entity_class
      Bronze::Entities::Operations::ValidateOneOperation.new(entity_class)
    end # method validate_attributes_operation

    def validate_uniqueness_operation entity_class
      Bronze::Entities::Operations::ValidateOneUniquenessOperation.
        new(entity_class, repository)
    end # method validate_uniqueness_operation
  end # class
end # module
