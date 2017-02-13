# lib/patina/operations/entities/find_one_operation.rb

require 'sleeping_king_studios/tools/toolbelt'

require 'bronze/operations/operation'

require 'patina/operations/entities'
require 'patina/operations/entities/error_messages'
require 'patina/operations/entities/transforms/persistence_transform'

module Patina::Operations::Entities
  # Queries the repository for the record with the given class and primary key.
  class FindOneOperation < Bronze::Operations::Operation
    include Patina::Operations::Entities::ErrorMessages

    # @param repository [Bronze::Collections::Repository] The repository used to
    #   query the resource and any child resources.
    # @param resource_class [Class] The class of entity to query for.
    def initialize repository, resource_class
      @repository     = repository
      @resource_class = resource_class
    end # constructor

    # @return [Bronze::Collections::Repository] The repository used to query the
    #   resource and any child resources.
    attr_reader :repository

    # @return [Bronze::Entities::Entity] The found resource, if any.
    attr_reader :resource

    # @return [Class] The class of entity to query for.
    attr_reader :resource_class

    private

    def collection
      repository.collection(plural_resource_name.intern, transform)
    end # method collection

    def plural_resource_name
      @plural_resource_name ||= tools.string.pluralize(resource_name)
    end # method plural_resource_name

    def process primary_key
      raise ArgumentError, "can't be nil" if primary_key.nil?

      @resource = collection.find(primary_key)

      return if @resource

      @failure_message = RECORD_NOT_FOUND

      error_definitions = Bronze::Collections::Collection::Errors

      @errors[plural_resource_name][primary_key].add(
        error_definitions::RECORD_NOT_FOUND,
        :id => primary_key
      ) # end errors
    end # method process

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
  end # class
end # module
