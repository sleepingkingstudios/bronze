# lib/patina/collections/mongo/query.rb

require 'bronze/collections/query'
require 'bronze/transforms/transform_chain'

require 'patina/collections/mongo'
require 'patina/collections/mongo/primary_key_transform'

criteria_pattern = File.join(
  Patina.lib_path, 'patina', 'collections', 'mongo', 'criteria',
  '*criterion.rb'
) # end pattern
SleepingKingStudios::Tools::CoreTools.require_each(criteria_pattern)

module Patina::Collections::Mongo
  # Implementation of Bronze::Collections::Query for a MongoDB schemaless
  # datastore.
  #
  # @see Mongo::Collection
  class Query < Bronze::Collections::Query
    # @param mongo_collection [::Mongo::Collection] The collection object for
    #   the data from the native Mongo ruby driver.
    # @param transform [Bronze::Transform] The transform object to map raw data
    #   into entities.
    def initialize mongo_collection, transform
      @mongo_collection = mongo_collection

      self.transform = transform
    end # method initialize

    # @return [::Mongo::Collection] The collection object for the data from the
    #   native Mongo ruby driver.
    attr_reader :mongo_collection

    # (see Bronze::Collections::Query#count)
    def count
      filtered        = apply_criteria
      criterion_class = Patina::Collections::Mongo::Criteria::LimitCriterion

      if criteria.any? { |criterion| criterion.is_a?(criterion_class) }
        filtered.to_a.size
      else
        filtered.count
      end # if-else
    end # method count

    # (see Bronze::Collections::Query#count)
    def matching selector
      super primary_key_transform.normalize(selector)
    end # method matching

    # (see Bronze::Collections::Query#limit)
    def limit count
      count.zero? ? none : super
    end # method matching

    protected

    # rubocop:disable Metrics/MethodLength
    def transform= transform
      @transform =
        if transform.is_a?(PrimaryKeyTransform)
          transform
        elsif transform.is_a?(Bronze::Transforms::TransformChain) &&
              transform.transforms.last.is_a?(PrimaryKeyTransform)
          transform
        else
          Bronze::Transforms::TransformChain.new(
            transform,
            primary_key_transform
          )
        end # if-elsif-else
    end # method transform=
    # rubocop:enable Metrics/MethodLength

    private

    def apply_criteria
      selector, options = super([{}, {}])

      mongo_collection.find(selector, options)
    end # method apply_criteria

    def criteria_namespace
      Patina::Collections::Mongo::Criteria
    end # method criteria_namespace

    def find_each
      apply_criteria.each { |hsh| yield hsh }
    end # method find_each

    def primary_key_transform
      @primary_key_transform ||= PrimaryKeyTransform.new
    end # method primary_key_transform
  end # class
end # module
