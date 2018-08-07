require 'cuprum/command_factory'

require 'bronze/entities/operations/assign_one_operation'
require 'bronze/entities/operations/build_one_operation'
require 'bronze/entities/operations/delete_one_operation'
require 'bronze/entities/operations/find_many_operation'
require 'bronze/entities/operations/find_matching_operation'
require 'bronze/entities/operations/find_one_operation'
require 'bronze/entities/operations/insert_one_operation'
require 'bronze/entities/operations/update_one_operation'
require 'bronze/entities/operations/validate_one_operation'

module Bronze::Entities::Operations
  # Factory class for generating entity operations with a given entity class and
  # configuration options.
  class EntityOperationFactory < Cuprum::CommandFactory
    def initialize(entity_class, contract: nil, repository: nil, transform: nil)
      @entity_class = entity_class
      @contract     = contract
      @repository   = repository
      @transform    = transform
    end

    attr_reader :contract

    attr_reader :entity_class

    attr_reader :repository

    attr_reader :transform

    command_class :assign_one do
      Bronze::Entities::Operations::AssignOneOperation.subclass(entity_class)
    end

    command_class :build_one do
      Bronze::Entities::Operations::BuildOneOperation.subclass(entity_class)
    end

    command_class :delete_one do
      Bronze::Entities::Operations::DeleteOneOperation
        .subclass(entity_class, **keywords)
    end

    command_class :find_many do
      Bronze::Entities::Operations::FindManyOperation
        .subclass(entity_class, **keywords)
    end

    command_class :find_matching do
      Bronze::Entities::Operations::FindMatchingOperation
        .subclass(entity_class, **keywords)
    end

    command_class :find_one do
      Bronze::Entities::Operations::FindOneOperation
        .subclass(entity_class, **keywords)
    end

    command_class :insert_one do
      Bronze::Entities::Operations::InsertOneOperation
        .subclass(entity_class, **keywords)
    end

    command_class :update_one do
      Bronze::Entities::Operations::UpdateOneOperation
        .subclass(entity_class, **keywords)
    end

    command_class :validate_one do
      Bronze::Entities::Operations::ValidateOneOperation
        .subclass(entity_class, **keywords)
    end

    private

    def keywords
      [:contract, :repository, :transform]
        .each.with_object({}) do |keyword, hsh|
          value = send(keyword)

          hsh[keyword] = value unless value.nil?
        end
    end
  end
end
