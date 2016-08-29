# spec/bronze/collections/reference/query.rb

require 'bronze/collections/query'

criteria_pattern = File.join(
  Bronze.gem_path, 'spec', 'bronze', 'collections', 'reference', 'criteria',
  '*criterion.rb'
) # end pattern
SleepingKingStudios::Tools::CoreTools.require_each(criteria_pattern)

module Spec::Reference
  # A reference implementation of Bronze::Collections::Query that uses a Ruby
  # Array as its data source.
  class Query < Bronze::Collections::Query
    # @param data [Array[Hash]] The source data for the query.
    # @param transform [Bronze::Transforms::Transform] The transform
    #   object to map raw data into entities.
    def initialize data, transform
      @data      = data
      @transform = transform
    end # constructor

    # (see Query#count)
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
