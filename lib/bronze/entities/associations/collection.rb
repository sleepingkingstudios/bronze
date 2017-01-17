# lib/bronze/entities/associations/collection.rb

require 'sleeping_king_studios/tools/toolbox/delegator'

require 'bronze/entities/associations'
require 'bronze/entities/associations/helpers'

module Bronze::Entities::Associations
  # Collection object for *_many associations.
  class Collection
    extend  SleepingKingStudios::Tools::Toolbox::Delegator
    include Enumerable
    include Bronze::Entities::Associations::Helpers

    # @param entity [Bronze::Entities::Entity] The entity that the collection
    #   belongs to; inverse of entity.(collection_name).
    # @param metadata [Associations::Metadata::HasManyMetadata] The metadata for
    #   the association.
    def initialize entity, metadata, entities = []
      @entity   = entity
      @metadata = metadata
      @entities = entities
    end # constructor

    # @return [Bronze::Entities::Entity] The entity that the collection belongs
    #   to.
    attr_reader :entity

    # @return [Associations::Metadata::HasManyMetadata] The metadata for the
    #   association.
    attr_reader :metadata

    # @!method count
    #   # @return [Integer] The number of entities in the collection.

    # @!method each
    #   # @yield [Entity] Yields each entity to the given block.

    # @!method empty?
    #   # @return [Integer] True if the collection has no entities, otherwise
    #     false.
    delegate \
      :count,
      :each,
      :empty?,
      :to => :@entities

    # Adds the specified entity to the collection, if it is not already part of
    # the collection.
    #
    # @param value [Entity] The entity to add.
    #
    # @return [Collection] The collection.
    #
    # @raise ArgumentError if the object is not a valid entity for the
    #   association.
    def << new_value
      add new_value

      self
    end # method <<

    # @return [Boolean] True if the other object is an array or collection and
    #   contains the same entities, otherwise false.
    def == other
      return true if other.is_a?(Array) && other == entities

      return true if other.is_a?(self.class) && other.entities == entities

      false
    end # method ==

    # Adds the specified entity to the collection, if it is not already part of
    # the collection.
    #
    # @param new_value [Entity] The entity to add.
    #
    # @return [Entity] The added entity.
    #
    # @raise ArgumentError if the object is not a valid entity for the
    #   association.
    def add new_value
      validate_association! metadata, new_value, :allow_nil => false

      # 1. Locally cache prior values
      inverse_metadata = metadata.inverse_metadata

      # 2. Break if collection already includes the value.
      return if @entities.include?(new_value)

      # 3. Set local values
      @entities << new_value

      # 4. Set new inverse
      if inverse_metadata
        new_value.send(inverse_metadata.writer_name, entity)
      end # if

      new_value
    end # method add

    # Removes all entities from the collection.
    #
    # @return [Collection] The empty collection.
    def clear
      return self if empty?

      entities         = @entities.dup
      inverse_metadata = metadata.inverse_metadata

      @entities.clear

      entities.each do |deleted|
        if inverse_metadata
          deleted.send(inverse_metadata.writer_name, nil)
        end # if
      end # each

      self
    end # method clear

    # @return [Integer] The number of entities in the collection.
    def count
      @entities.count
    end # method count

    # rubocop:disable Metrics/MethodLength

    # Removes the specified entity from the collection.
    #
    # @param prior_value [Entity, Object] The entity to remove, or the primary
    #   key of the entity to remove.
    #
    # @return [Entity] The removed entity, or nil if the entity was not in the
    #   collection.
    #
    # @raise ArgumentError if the object is not a valid entity for the
    #   association.
    def delete prior_value
      validate_association! \
        metadata,
        prior_value,
        :allow_nil         => false,
        :allow_primary_key => true

      # 1. Locally cache prior values
      inverse_metadata = metadata.inverse_metadata
      primary_key      =
        if prior_value.is_a?(metadata.association_class)
          prior_value.id
        else
          prior_value
        end # if-else

      # 2. Break if collection already includes the value.
      index = @entities.find_index { |item| item.id == primary_key }

      return unless index

      # 3. Set local values
      deleted = @entities.delete_at index

      # 4. Set new inverse
      if inverse_metadata
        deleted.send(inverse_metadata.writer_name, nil)
      end # if

      prior_value
    end # method delete
    # rubocop:enable Metrics/MethodLength

    # Returns the collection entities as an immutable array.
    #
    # @return [Array<Entity>] The entities in the collection.
    def to_a
      @entities.dup.freeze
    end # method to_a

    protected

    attr_reader :entities
  end # class
end # module
