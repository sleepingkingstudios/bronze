# lib/patina/operations/entities/persistence_operation.rb

require 'sleeping_king_studios/tools/toolbelt'

require 'patina/operations/entities'
require 'patina/operations/entities/transforms/persistence_transform'

module Patina::Operations::Entities
  # Shared functionality for operations that query a resource from a repository
  # or persist the resource to the repository.
  module PersistenceOperation
    # @param repository [Bronze::Collections::Repository] The repository used to
    #   query the resource and any child resources.
    # @param resource_class [Class] The class of entity to query for.
    # @param transform [Bronze::Transforms::Transform] The transform used to
    #   query or persist the resource.
    def initialize repository, resource_class, transform = nil
      @repository     = repository
      @resource_class = resource_class
      @transform      = transform
    end # constructor

    # @return [Bronze::Collections::Repository] The repository used to query the
    #   resource and any child resources.
    attr_reader :repository

    # @return [Class] The class of entity to query for.
    attr_reader :resource_class

    private

    def collection
      @collection ||= repository.collection(plural_resource_name, transform)
    end # method collection

    def plural_resource_name
      @plural_resource_name ||= tools.string.pluralize(resource_name)
    end # method plural_resource_name

    def resource_name
      @resource_name ||=
        begin
          name = resource_class.name.split('::').last
          name = tools.string.underscore(name)

          tools.string.singularize(name)
        end # resource_name
    end # method resource_name

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end # method tools

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
