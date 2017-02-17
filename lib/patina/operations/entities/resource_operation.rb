# lib/patina/operations/entities/resource_operation.rb

require 'sleeping_king_studios/tools/toolbelt'

require 'patina/operations/entities'

module Patina::Operations::Entities
  # Shared functionality for operations that reference or name a resource.
  module ResourceOperation
    # @param resource_class [Class] The class of entity referenced.
    def initialize resource_class
      @resource_class = resource_class
    end # constructor

    # @return [Class] The class of entity to query for.
    attr_reader :resource_class

    private

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
  end # module
end # module
