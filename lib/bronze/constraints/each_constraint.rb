# lib/bronze/constraints/each_constraint.rb

require 'bronze/constraints/contextual_constraint'

module Bronze::Constraints
  # Wrapper object that encapsulates a constraint object and additional metadata
  # and evaluates the wrapped constraint against each item in a collection.
  class EachConstraint < ContextualConstraint
    # Error message for matched objects that are not collections.
    NOT_A_COLLECTION_ERROR =
      'constraints.errors.messages.not_a_collection'.freeze

    private

    def apply_with_arity proc, object, index_or_key, collection
      if proc.arity >= 4
        object.instance_exec(object, index_or_key, collection, property, &proc)
      elsif proc.arity >= 3
        object.instance_exec(object, index_or_key, collection, &proc)
      elsif proc.arity >= 1
        object.instance_exec(object, &proc)
      else
        object.instance_exec(&proc)
      end # if-else
    end # method apply_with_arity

    def matches_array? array, negated:
      array.each.with_index.reduce(true) do |memo, (item, index)|
        next memo if skip?(item, index, array)

        result = matches_item?(item, index, :negated => negated)

        memo && result
      end # reduce
    end # method matches_array?

    def matches_hash? hash, negated:
      hash.each.reduce(true) do |memo, (key, value)|
        next memo if skip?(value, key, hash)

        result = matches_item?(value, key, :negated => negated)

        memo && result
      end # reduce
    end # method matches_hash?

    def matches_item? item, index_or_key, negated:
      value        = extract_value item
      nesting      = errors[index_or_key]
      match_method = negated ? :negated_match : :match

      result, _ = constraint.send(match_method, value, nesting)

      result
    end # method matches_object?

    def matches_object? object
      negated = negated? ? true : false

      return matches_array?(object, :negated => negated) if object.is_a?(Array)

      return matches_hash?(object,  :negated => negated) if object.is_a?(Hash)

      errors.add(NOT_A_COLLECTION_ERROR)

      false
    end # method matches_object?

    def negated_matches_object? object
      negated = negated? ? false : true

      return matches_array?(object, :negated => negated) if object.is_a?(Array)

      return matches_hash?(object,  :negated => negated) if object.is_a?(Hash)

      errors.add(NOT_A_COLLECTION_ERROR)

      false
    end # method negated_matches_object?

    def skip? *params
      if @if_condition
        return true unless apply_with_arity(@if_condition, *params)
      elsif @unless_condition
        return true if apply_with_arity(@unless_condition, *params)
      end # if-elsif

      false
    end # method skip?
  end # class
end # module
