# lib/patina/repositories/simple.rb

require 'patina/repositories'

module Patina::Repositories
  # A basic implementation of Bronze::Repositories::Collection with an in-memory
  # hash data store. Not recommended for production or mission-critical use, but
  # works as a drop-in replacement for a dedicated datastore during development
  # or as a dependency in unit tests.
  #
  # @see Simple::Collection
  module Simple; end
end # module
