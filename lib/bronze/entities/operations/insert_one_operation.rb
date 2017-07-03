# lib/bronze/entities/operations/insert_one_operation.rb

require 'bronze/entities/operations/insert_one_without_validation_operation'
require 'bronze/entities/operations/persistence_operation'
require 'bronze/entities/operations/validate_one_operation'
require 'bronze/entities/operations/validate_one_uniqueness_operation'
require 'bronze/operations/operation_chain'

module Bronze::Entities::Operations
  # Operation for validating the given entity and, if valid, inserting the
  # entity into the repository.
  class InsertOneOperation < Bronze::Operations::OperationChain
    include Bronze::Entities::Operations::PersistenceOperation

    # @param entity_class [Class] The class of entity this operation acts upon.
    # @param repository [Bronze::Collections::Repository] The data repository to
    #   access or reference.
    def initialize entity_class, repository
      first_operation = validate_attributes_operation(entity_class)

      super(entity_class, repository, first_operation)

      self.
        then(validate_uniqueness_operation entity_class).
        then(insert_operation entity_class)
    end # constructor

    private

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
  end # module
end # module
