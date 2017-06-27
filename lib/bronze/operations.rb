# lib/bronze/operations.rb

require 'bronze'

module Bronze
  # Namespace for operation classes, which encapsulate a process or procedure of
  # business logic with a consistent architecture and interface.
  module Operations
    autoload :Operation,      'bronze/operations/operation'
    autoload :OperationChain, 'bronze/operations/operation_chain'
  end # module
end # module
