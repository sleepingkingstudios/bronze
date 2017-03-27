# lib/patina/operations/entities/persistence_operation.rb

require 'patina/operations/entities'
require 'patina/operations/entities/resource_operation'
require 'patina/operations/entities/transforms/persistence_transform'

module Patina::Operations::Entities
  # Shared functionality for operations that query a resource from a repository
  # or persist the resource to the repository.
  module PersistenceOperation
    include Patina::Operations::Entities::ResourceOperation

    # @param repository [Bronze::Collections::Repository] The repository used to
    #   query the resource and any child resources.
    # @param resource_class [Class] The class of entity to query for.
    # @param transform [Bronze::Transforms::Transform] The transform used to
    #   query or persist the resource.
    def initialize repository, resource_class, transform = nil
      @repository = repository
      @transform  = transform

      super(resource_class)
    end # constructor

    # @return [Bronze::Collections::Repository] The repository used to query the
    #   resource and any child resources.
    attr_reader :repository

    private

    def collection
      @collection ||= repository.collection(resource_class, transform)
    end # method collection

    def transform
      @transform ||=
        begin
          transform_class =
            Patina::Operations::Entities::Transforms::PersistenceTransform

          transform_class.new(resource_class)
        end # begin
    end # method transform
  end # module
end # module
