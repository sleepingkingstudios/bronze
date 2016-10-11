# lib/bronze/contracts/contractable.rb

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/contracts/contract'

module Bronze::Contracts
  # Helper mixin for defining a canonical contract for a type, such as required
  # attributes on an entity.
  module Contractable
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    # Class methods to define when including Contractable in a class.
    module ClassMethods
      def contract &block
        @contract ||= Bronze::Contracts::Contract.new

        @contract.instance_exec(&block) if block_given?

        @contract
      end # class method contract
    end # module
  end # module
end # module
