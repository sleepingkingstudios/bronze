# lib/bronze/operations/repository_operation.rb

require 'bronze/operations'

module Bronze::Operations
  # Shared functionality for operations that interact with a datastore,
  # represented by a Bronze::Collections::Repository object.
  module RepositoryOperation
    # @return [Bronze::Collections::Repository] The repository used to persist
    #   and query the resource and any child resources.
    attr_reader :repository

    protected

    attr_writer :repository
  end # module
end # module
