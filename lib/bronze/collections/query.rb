# lib/bronze/collections/query.rb

require 'bronze/collections'

criteria_pattern = File.join(
  Bronze.gem_path, 'lib', 'bronze', 'collections', 'criteria', '*criterion.rb'
) # end pattern
SleepingKingStudios::Tools::CoreTools.require_each(criteria_pattern)

module Bronze::Collections
  # Abstract class for performing queries against a datastore using a consistent
  # interface, whether it is a SQL database, a Mongoid datastore, or an
  # in-memory data structure.
  class Query
    # Error class for handling unimplemented abstract query methods. Subclasses
    # of Query must implement these methods as appropriate for the datastore.
    class NotImplementedError < StandardError; end

    # The current transform object. The transform maps the raw data returned by
    # the datastore to another object, typically an entity.
    #
    # If a transform is set, it will be used to map all data retrieved from the
    # datastore into the respective entities.
    #
    # @return [Bronze::Entities::Transform] The transform object.
    attr_reader :transform

    # Performs a count on the dataset.
    #
    # @return [Integer] The number of items matching the query.
    def count
      raise NotImplementedError,
        "#{self.class.name} does not implement :count",
        caller
    end # method count

    # Creates a copy of the query, preserving the criteria and transform but not
    # any cached data.
    #
    # @return [Query]
    def dup
      query = super
      query.criteria = criteria.dup
      query
    end # method dup

    # Executes the query, if applicable, and yields each result to the block.
    #
    # @yieldparam hsh [Hash] The current result.
    def each &block
      find_each { |hsh| block.call(transform.denormalize hsh) }
    end # method each

    # Checks if any items exist in the datastore that match the given criteria.
    #
    # @return [Boolean] True if there are matching items, otherwise false.
    def exists?
      limit(1).count > 0
    end # method exists?

    # Returns a copy of the query with an added limit criteria.
    #
    # @param count [Integer] The maximum number of results to return.
    #
    # @return [Query] The copied query.
    def limit count
      dup.tap do |query|
        query.criteria << build_criterion(:limit, count)
      end # tap
    end # method matching

    # Returns a copy of the query with an added match criteria.
    #
    # @param selector [Hash] The properties and values that the returned data
    #   must match.
    #
    # @return [Query] The copied query.
    def matching selector
      dup.tap do |query|
        query.criteria << build_criterion(:match, selector)
      end # tap
    end # method matching

    # If there is exactly one item matching the given criteria, returns the
    # item; otherwise returns nil.
    #
    # @return [Hash, nil] The item, or nil.
    def one
      results = limit(2).to_a

      results.count == 1 ? results.first : nil
    end # method one

    # Returns an empty query.
    #
    # @return [NullQuery] The empty query.
    def none
      NullQuery.new
    end # method none

    # Iterates through the data matching the given criteria and returns the
    # value of the specified attribute for each data object.
    #
    # @param attribute_name [Symbol] The name of the attribute.
    #
    # @return [Array] The value of the attribute for each object.
    def pluck attribute_name
      [].tap { |ary| find_each { |obj| ary << obj[attribute_name] } }
    end # method pluck

    # Executes the query, if applicable, and returns the results as an array of
    # attribute hashes.
    #
    # @return [Array[Hash]] The data objects matching the query.
    def to_a
      results = []

      find_each { |hsh| results << transform.denormalize(hsh) }

      results
    end # method to_a

    protected

    attr_writer :criteria

    def criteria
      @criteria ||= []
    end # method criteria

    private

    def apply_criteria native_query
      tools = ::SleepingKingStudios::Tools::ArrayTools

      filters, rest = tools.bisect(criteria) do |criterion|
        criterion.type == :filter
      end # bisect

      [filters, rest].each do |criteria|
        criteria.each do |criterion|
          native_query = criterion.call(native_query)
        end # each
      end # each

      native_query
    end # method apply_criteria

    def build_criterion type, *args, &block
      tools          = SleepingKingStudios::Tools::StringTools
      criterion_name = "#{tools.camelize(type.to_s)}Criterion"

      unless criteria_namespace.const_defined? criterion_name
        raise NotImplementedError,
          "undefined criterion #{criteria_namespace}::#{criterion_name}",
          caller
      end # unless

      criterion_class = criteria_namespace.const_get(criterion_name)
      criterion_class.new(*args, &block)
    end # method build_criterion

    def criteria_namespace
      Criteria
    end # method criteria_namespace

    def find_each
      raise NotImplementedError,
        "#{self.class.name} does not implement :find_each",
        caller
    end # method find_each
  end # class
end # module

require 'bronze/collections/null_query'
