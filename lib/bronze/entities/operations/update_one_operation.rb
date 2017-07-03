# lib/bronze/entities/operations/update_one_operation.rb

require 'bronze/entities/operations/persistence_operation'
require 'bronze/entities/operations/validate_one_operation'
require 'bronze/entities/operations/validate_one_uniqueness_operation'
require 'bronze/entities/operations/update_one_without_validation_operation'
require 'bronze/operations/operation_chain'

module Bronze::Entities::Operations
  # Operation for validating the given entity and, if valid, updating the
  # entity in the repository.
  class UpdateOneOperation < Bronze::Operations::OperationChain
    include Bronze::Entities::Operations::PersistenceOperation

    # @param entity_class [Class] The class of entity this operation acts upon.
    # @param repository [Bronze::Collections::Repository] The data repository to
    #   access or reference.
    def initialize entity_class, repository
      first_operation = validate_attributes_operation(entity_class)

      super(entity_class, repository, first_operation)

      self.
        then(validate_uniqueness_operation entity_class).
        then(update_operation entity_class)
    end # constructor

    private

    def update_operation entity_class
      Bronze::Entities::Operations::UpdateOneWithoutValidationOperation.
        new(entity_class, repository)
    end # method update_operation

    def validate_attributes_operation entity_class
      Bronze::Entities::Operations::ValidateOneOperation.new(entity_class)
    end # method validate_attributes_operation

    def validate_uniqueness_operation entity_class
      Bronze::Entities::Operations::ValidateOneUniquenessOperation.
        new(entity_class, repository)
    end # method validate_uniqueness_operation
  end # module
end # module
