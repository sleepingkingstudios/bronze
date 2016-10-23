# lib/bronze/contracts/type_contract.rb

require 'sleeping_king_studios/tools/toolbox/delegator'
require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/contracts/contract_builder'

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
        @contract ||= Bronze::Contracts::Contract.new
        @builder  ||= Bronze::Contracts::ContractBuilder.new(@contract)

        @builder.instance_exec(&block) if block_given?

        @contract
      end # class method contract
    end # module
  end # module
end # module
