# lib/bronze/contracts/type_contract.rb

require 'sleeping_king_studios/tools/toolbox/delegator'
require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/contracts/contract'

module Bronze::Contracts
  # Helper mixin for defining a canonical contract for a type, such as required
  # attributes on an entity.
  module TypeContract
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    # Class methods to define when including TypeContract in a class.
    module ClassMethods
      extend SleepingKingStudios::Tools::Toolbox::Delegator

      delegate :match, :to => :contract

      def contract &block
        @contract ||= build_contract

        @contract.instance_exec(&block) if block_given?

        @contract
      end # class method contract

      private

      def build_contract
        Bronze::Contracts::Contract.new
      end # method contract_builder
    end # module
  end # module
end # module
