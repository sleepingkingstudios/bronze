# lib/patina/operations/entities/build_one_operation.rb

require 'sleeping_king_studios/tools/toolbelt'

require 'bronze/operations/operation'

require 'patina/operations/entities'

module Patina::Operations::Entities
  # Builds an instance of the given resource class with the given attributes.
  class BuildOneOperation < Bronze::Operations::Operation
    # @param resource_class [Class] The class of entity to build.
    def initialize resource_class
      @resource_class = resource_class
    end # constructor

    # @return [Bronze::Entities::Entity] The built resource.
    attr_reader :resource

    # @return [Class] The class of entity to build.
    attr_reader :resource_class

    private

    def process attributes
      attributes = tools.hash.convert_keys_to_symbols(attributes || {})
      @resource  = resource_class.new(attributes)
    end # method process

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end # method tools
  end # class
end # module
