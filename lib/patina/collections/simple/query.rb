# lib/patina/collections/simple/query.rb

require 'bronze/collections/query'

require 'patina/collections/simple'

criteria_pattern = File.join(
  Patina.lib_path, 'patina', 'collections', 'simple', 'criteria',
  '*criterion.rb'
) # end pattern
SleepingKingStudios::Tools::CoreTools.require_each(criteria_pattern)

module Patina::Collections::Simple
  # Implementation of Bronze::Collections::Query for an Array-of-Hashes
  # in-memory data store.
  #
  # @see Simple::Collection
  class Query < Bronze::Collections::Query
    # @param data [Array[Hash]] The source data for the query.
    # @param transform [Bronze::Transform] The transform object to map raw data
    #   into entities.
    def initialize data, transform
      @data      = data
      @transform = transform
    end # method initialize

    # (see Bronze::Collections::Query#count)
    def count
      filtered = apply_criteria(@data)
      filtered.count
    end # method count

    private

    def criteria_namespace
      Patina::Collections::Simple::Criteria
    end # method criteria_namespace

    def find_each
      apply_criteria(@data).each { |hsh| yield hsh }
    end # method find_each
  end # class
end # module
