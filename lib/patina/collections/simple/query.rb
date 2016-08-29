# lib/patina/collections/simple/query.rb

require 'bronze/collections/query'
require 'patina/collections/simple'

criteria_pattern = File.join(
  Bronze.gem_path, 'lib', 'patina', 'collections', 'simple', 'criteria',
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
    # @param transform [Bronze::Transforms::Transform] The transform
    #   object to map raw data into entities.
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
      Spec::Reference::Criteria
    end # method criteria_namespace

    def find_each
      filtered = apply_criteria(@data)
      filtered.map { |hsh| yield hsh }
    end # method find_each
  end # class
end # module
