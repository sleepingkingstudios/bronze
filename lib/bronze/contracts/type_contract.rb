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

      def contract contract_or_class = nil, &block
        if contract_class?(contract_or_class)
          @contract = contract_or_class.new
        elsif contract_or_class.is_a?(Bronze::Contracts::Contract)
          @contract = contract_or_class
        else
          @contract ||= build_contract
        end # if-else

        @contract.instance_exec(&block) if block_given?

        @contract
      end # class method contract

      private

      def build_contract
        Bronze::Contracts::Contract.new
      end # method contract_builder

      def contract_class? object
        object.is_a?(Class) && object < Bronze::Contracts::Contract
      end # method contract_class?
    end # module
  end # module
end # module
