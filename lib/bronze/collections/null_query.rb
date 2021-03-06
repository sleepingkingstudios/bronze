# lib/bronze/collections/null_query.rb

require 'bronze/collections/query'

module Bronze::Collections
  # A query object representing an empty dataset.
  class NullQuery < Query
    # (see Query#count)
    def count
      0
    end # method count

    # rubocop:disable Lint/UnusedMethodArgument

    # (see Query#limit)
    def limit count
      self
    end # method limit

    # (see Query#matching)
    def matching selector
      self
    end # method matching

    # (see Query#pluck)
    def pluck attribute_name
      []
    end # method pluck

    # rubocop:enable Lint/UnusedMethodArgument

    # (see Query#to_a)
    def to_a
      []
    end # method to_a
  end # class
end # module
