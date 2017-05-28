# lib/bronze/entities/uniqueness.rb

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'bronze/entities'
require 'bronze/entities/constraints/uniqueness_constraint'

module Bronze::Entities
  # Module for defining a uniqueness constraints on an entity.
  module Uniqueness
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    # Class methods to define when including Uniqueness in a class.
    module ClassMethods
      # Constrains the entity to be unique within a given collection based on
      # the given attribute(s). If multiple attributes are given, then all of
      # the attributes must match the collection item; to check the uniqueness
      # of attributes independently, call ::unique once for each attribute.
      #
      # @param attributes [Array<String, Symbol>] The attribute or attributes
      #   which must be unique within a collection.
      def unique *attributes
        constraint =
          Bronze::Entities::Constraints::UniquenessConstraint.new(*attributes)

        uniqueness_constraints << constraint
      end # method unique

      private

      def uniqueness_constraints
        @uniqueness_constraints ||= []
      end # method uniqueness_constraints
    end # module

    # Checks the collection for the uniqueness of the entity. An entity is
    # considered unique if there are no entries in the collection that match
    # unique attributes of the entity but with different primary keys.
    #
    # @param collection [Bronze::Collections::Collection] The data store to
    #   check for matching entries.
    #
    # @return [Array<Boolean, Bronze::Errors::Errors>] True and an empty errors
    #   object if the entity is unique, otherwise false and an errors object
    #   with details on the failing expectation.
    def match_uniqueness collection
      errors = Bronze::Errors.new

      self.class.send(:uniqueness_constraints).each do |constraint|
        _, err = constraint.with_collection(collection).match(self)

        errors = errors.merge(err) unless err.empty?
      end # each

      [errors.empty?, errors]
    end # method match_uniqueness
  end # module
end # module
