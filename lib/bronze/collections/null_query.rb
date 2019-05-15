# frozen_string_literal: true

require 'bronze/collections'
require 'bronze/collections/query'

module Bronze::Collections
  # Null object implementation of Query, which implements the Query methods
  # against an empty dataset.
  class NullQuery < Bronze::Collections::Query
    # (see Bronze::Collections::Query#count)
    def count
      0
    end

    # (see Bronze::Collections::Query#each)
    def each
      return [].each unless block_given?
    end

    # (see Bronze::Collections::Query#exists?)
    def exists?
      false
    end

    # (see Bronze::Collections::Query#limit)
    def limit(_count)
      self
    end

    # (see Bronze::Collections::Query#matching)
    def matching(_selector)
      self
    end
    alias_method :where, :matching

    # (see Bronze::Collections::Query#offset)
    def offset(_count)
      self
    end
    alias_method :skip, :offset

    # (see Bronze::Collections::Query#order)
    def order(*_attributes)
      self
    end
  end
end
