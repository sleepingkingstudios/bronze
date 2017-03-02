# lib/patina/operations/entities/build_one_operation.rb

require 'sleeping_king_studios/tools/toolbelt'

require 'bronze/operations/operation'

require 'patina/operations/entities'
require 'patina/operations/entities/resource_operation'

module Patina::Operations::Entities
  # Builds an instance of the given resource class with the given attributes.
  class BuildOneOperation < Bronze::Operations::Operation
    include Patina::Operations::Entities::ResourceOperation

    # @return [Bronze::Entities::Entity] The built resource.
    attr_reader :resource

    private

    def process attributes
      attributes = tools.hash.convert_keys_to_symbols(attributes || {})

      @resource = resource_class.new(attributes)
    end # method process
  end # class
end # module
