# lib/patina/collections/mongo/collection.rb

require 'bronze/collections/collection'

require 'patina/collections/mongo'
require 'patina/collections/mongo/primary_key_transform'
require 'patina/collections/mongo/query'
require 'patina/collections/validation'

module Patina::Collections::Mongo
  # Implementation of Bronze::Collections::Collection for a MongoDB
  # schemaless datastore.
  #
  # @see Mongo::Query
  class Collection
    include Bronze::Collections::Collection
    include Patina::Collections::Validation

    # @param mongo_collection [::Mongo::Collection] The collection object for
    #   the data from the native Mongo ruby driver.
    # @param transform [Bronze::Entities::Transform] The transform object used
    #   to map collection objects to and from raw data.
    def initialize mongo_collection, transform = nil
      @mongo_collection = mongo_collection

      self.transform = transform || default_transform
    end # constructor

    # @return [::Mongo::Collection] The collection object for the data from the
    #   native Mongo ruby driver.
    attr_reader :mongo_collection

    protected

    # rubocop:disable Metrics/MethodLength
    def transform= transform
      @transform =
        if transform.is_a?(PrimaryKeyTransform)
          transform
        elsif transform.is_a?(Bronze::Transforms::TransformChain) &&
              transform.transforms.last.is_a?(PrimaryKeyTransform)
          transform
        elsif transform.is_a?(Bronze::Transform)
          Bronze::Transforms::TransformChain.new(
            transform,
            primary_key_transform
          )
        else
          default_transform
        end # if-elsif-else
    end # method transform=
    # rubocop:enable Metrics/MethodLength

    private

    def base_query
      Patina::Collections::Mongo::Query.new(mongo_collection, transform)
    end # method base_query

    def build_mongo_operation_failure_errors message, id, attributes
      # rubocop:disable Style/EmptyCaseCondition
      case
      when message.include?('cannot change _id'),           # MongoDB 2.x
           message.include?('_id field cannot be changed'), # MongoDB 3.?
           message.include?("field '_id' was found to have been altered")
        build_primary_key_invalid_error(id, attributes)
      when message.include?('duplicate key error')
        build_errors.add(Errors.record_already_exists, :id => id)
      end # case
      # rubocop:enable Style/EmptyCaseCondition
    end # method build_mongo_operation_failure_errors

    def build_primary_key_invalid_error id, attributes
      primary_key = attributes['_id'] || attributes[:_id]

      build_errors.add(
        Errors.primary_key_invalid,
        :key      => :id,
        :expected => primary_key,
        :received => id
      ) # end errors
    end # method build_primary_key_invalid_error

    def clear_collection
      mongo_collection.delete_many({})

      []
    end # method clear_collection

    def default_transform
      primary_key_transform
    end # method default_transform

    def delete_one id
      errors = validate_id(id)

      return errors unless errors.empty?

      result = mongo_collection.delete_one('_id' => id)
      stats  = result.documents.first

      return [] if stats['n'] > 0

      build_errors.add(Errors.record_not_found, :id => id)
    end # method delete_one

    def handle_mongo_exceptions id, attributes
      yield
    rescue Mongo::Error::OperationFailure => exception
      errors =
        build_mongo_operation_failure_errors(exception.message, id, attributes)

      return errors if errors

      raise
    end # method handle_mongo_exceptions

    def insert_one attributes
      errors = validate_attributes(attributes)

      return errors unless errors.empty?

      primary_key = attributes['_id'] || attributes[:_id]

      errors = validate_id(primary_key)

      return errors unless errors.empty?

      handle_mongo_exceptions(primary_key, attributes) do
        mongo_collection.insert_one(attributes)

        []
      end # handle_mongo_exceptions
    end # method insert_one

    def primary_key_transform
      @primary_key_transform ||=
        Patina::Collections::Mongo::PrimaryKeyTransform.new
    end # method primary_key_transform

    def update_one id, attributes
      errors = validate_id(id)

      return errors unless errors.empty?

      errors = validate_attributes(attributes)

      return errors unless errors.empty?

      handle_mongo_exceptions(id, attributes) do
        result = mongo_collection.update_one({ '_id' => id }, attributes)
        stats  = result.documents.first

        return [] if stats['n'] > 0

        build_errors.add(Errors.record_not_found, :id => id)
      end # handle mongo_exceptions
    end # method update_one
  end # class
end # module
