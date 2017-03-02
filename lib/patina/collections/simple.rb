# lib/patina/collections/simple.rb

require 'patina/collections'

module Patina::Collections
  # A basic implementation of Bronze::Collections::Collection with an in-memory
  # hash data store. Not recommended for production or mission-critical use, but
  # works as a drop-in replacement for a dedicated datastore during development
  # or as a dependency in unit tests.
  #
  # @see Simple::Collection
  module Simple
    autoload :Collection, 'patina/collections/simple/collection'
    autoload :Repository, 'patina/collections/simple/repository'
  end # module
end # module
