# lib/patina/operations/resources/build_one_resource_operation.rb

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'patina/operations/resources/one_resource_operation'

module Patina::Operations::Resources
  # Operation module to build an instance of a resource from an attributes hash.
  module BuildOneResourceOperation
    extend  SleepingKingStudios::Tools::Toolbox::Mixin
    include Patina::Operations::Resources::OneResourceOperation

    private

    def process attributes
      build_resource(attributes)
    end # method process
  end # module
end # module
