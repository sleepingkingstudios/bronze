# lib/bronze/collections/constraints/collection_constraint.rb

require 'bronze/collections/constraints'

module Bronze::Collections::Constraints
  # Mixin for constraint classes that validate or relate to a collection
  # instance.
  module CollectionConstraint
    def with_collection collection, &block
      copy = dup.tap { |obj| obj.collection = collection }

      block_given? ? copy.instance_exec(&block) : copy
    end # method with_collection

    protected

    attr_accessor :collection

    private

    def require_collection
      return if collection

      raise RuntimeError,
        'specify a collection using the #with_collection method',
        caller(1..-1)
    end # method require_collection
  end # module
end # module
