# lib/patina/operations/entities/assign_one_operation.rb

require 'bronze/operations/operation'

require 'patina/operations/entities'

module Patina::Operations::Entities
  # Assigns the given attributes to the given resource.
  class AssignOneOperation < Bronze::Operations::Operation
    # @return [Bronze::Entities::Entity] The resource with assigned attributes.
    attr_reader :resource

    private

    def process resource, attributes
      raise ArgumentError, "resource can't be nil" unless resource

      @resource = resource

      resource.assign(attributes)
    end # method process
  end # class
end # module
