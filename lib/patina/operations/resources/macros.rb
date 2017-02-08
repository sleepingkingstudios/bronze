# lib/patina/operations/resources/macros.rb

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'patina/operations/resources'

operations_pattern = File.join(
  Patina.lib_path, 'patina', 'operations', 'resources', '*_operation.rb'
) # end pattern
SleepingKingStudios::Tools::CoreTools.require_each(operations_pattern)

module Patina::Operations::Resources
  # Helper methods for adding resourceful operation methods to an operation
  # class.
  module Macros
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    # Class methods to define when including Resources in a class.
    module ClassMethods
      class << self
        private

        def define_macro macro_name, operation_module
          mixin = operation_module

          define_method macro_name do |resource_or_name|
            include mixin

            self.resource_class =
              if resource_or_name.is_a?(Class)
                resource_or_name
              else
                resource_class_for(resource_or_name)
              end # if-else
          end # define_method
        end # class method define_macro
      end # eigenclass

      private

      def resource_class_for resource_name
        raise ArgumentError, "unknown resource #{resource_name.inspect}", caller
      end # method resource_class_for

      define_macro :build_one,
        Patina::Operations::Resources::BuildOneResourceOperation

      define_macro :create_one,
        Patina::Operations::Resources::CreateOneResourceOperation

      define_macro :destroy_one,
        Patina::Operations::Resources::DestroyOneResourceOperation

      define_macro :find_matching,
        Patina::Operations::Resources::FindMatchingResourcesOperation

      define_macro :find_one,
        Patina::Operations::Resources::FindOneResourceOperation

      define_macro :update_one,
        Patina::Operations::Resources::UpdateOneResourceOperation
    end # module
  end # module
end # module
