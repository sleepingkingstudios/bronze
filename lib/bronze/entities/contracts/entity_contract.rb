# lib/bronze/entities/contracts/entity_contract.rb

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/contracts/contract'
require 'bronze/contracts/type_contract'
require 'bronze/entities/constraints/entity_constraint_builder'

module Bronze::Entities::Contracts
  # Helper mixin for defining a canonical contract for an entity.
  module EntityContract
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    include Bronze::Contracts::TypeContract

    # Class methods to define when including TypeContract in a class.
    module ClassMethods
      private

      def build_contract
        Bronze::Contracts::Contract.new.tap do |contract|
          contract.extend Bronze::Entities::Constraints::EntityConstraintBuilder
        end # tap
      end # method contract_builder
    end # module
  end # module
end # module
