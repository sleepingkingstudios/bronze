# lib/bronze/errors.rb

require 'sleeping_king_studios/tools/toolbelt'

require 'bronze/errors'

module Bronze
  # rubocop:disable Metrics/ClassLength

  # Utility object that wraps a hash-of-hashes nested errors data structure.
  class Errors
    include Enumerable

    def initialize data: {}, path: []
      @path = path || []
      @data = data || {}

      @data[:__errors] ||= []
    end # method errors

    # Compares the given object to the errors. Returns false if the other object
    # is not an errors object or does not have the same errors.
    #
    # @param other [Bronze::Errors] The object to compare.
    #
    # @return [Boolean]
    def == other
      return false unless other.is_a?(Bronze::Errors)

      compare_errors(other)
    end # method ==

    # Returns a reference to the inner errors data structure at the given key.
    #
    # @param key [Integer, Symbol] The inner data key.
    #
    # @return [Bronze::Errors] The errors proxy for the referenced data.
    def [] key
      key = key.intern if key.is_a?(String)
      hsh =
        @data[key] ||= {}

      Bronze::Errors.new(:data => hsh, :path => path + [key])
    end # method []

    # Copies the hash and sets it as the inner errors data structure at the
    # given key.
    #
    # @param key [Integer, Symbol] The inner data key.
    # @param value [Hash, Bronze::Errors] The hash or errors proxy to copy.
    def []= key, value
      key  = key.intern if key.is_a?(String)
      data = value.is_a?(Bronze::Errors) ? value.data : value

      @data[key] = tools.hash.deep_dup(data)
    end # method []=

    # Adds an error with the specified type and params.
    #
    # @param type [String, Symbol] The error type.
    # @param params [Hash] Additional params for the error, if any.
    def add type, params = {}
      @data[:__errors] << { :type => type, :params => params }

      self
    end # method add

    # @return [Integer] The number of errors in the data structure.
    def count
      count_errors_in_hash @data
    end # method count
    alias_method :length, :count
    alias_method :size,   :count

    # Removes the inner data at the given key and returns it wrapped with proxy
    # object.
    #
    # @param key [Integer, Symbol] The inner data key.
    #
    # @return [Bronze::Errors] The errors proxy for the referenced data.
    def delete key
      Bronze::Errors.new :data => @data.delete(key)
    end # method delete

    # Returns a reference to the nested inner errors data structure referenced
    # by the given keys.
    #
    # @param keys [Array<Integer, Symbol>] The inner data keys.
    #
    # @return [Bronze::Errors] The errors proxy for the referenced data.
    def dig *keys
      keys.reduce(self) { |proxy, key| proxy[key] }
    end # method dig

    # @return [Bronze::Errors] A deep copy of the errors object.
    def dup
      self.class.new(:data => tools.hash.deep_dup(data), :path => path)
    end # method dup

    # Iterates through the errors in errors object and all child errors objects,
    # yielding each to the given block.
    #
    # @yieldparam error [Hash] The current error.
    def each
      return enum_for(:each) unless block_given?

      each_error_in_hash(@data, @path) { |error| yield error }
    end # method each

    # @return True if the data structure has no errors, otherwise false.
    def empty?
      !hash_has_errors?(@data)
    end # method empty?

    # Returns true if the data structure includes a matching error, otherwise
    # false. Each error in the data structure is compared to the expectation
    # using a hash subset comparison. If the expected object is not a hash, it
    # is converted to the form { :type => expected }.
    #
    # @param expected [Hash, Object] The expected error or error type.
    #
    # @return [Boolean] True if an error in the data structure matches the
    #   expectation, otherwise false.
    def include? expected
      expected = { :type => expected } unless expected.is_a?(Hash)

      any? { |error| error >= expected }
    end # method include?

    # @param key [Integer, Symbol] The inner data key.
    #
    # @return [Boolean] True if the data structure has the given key, otherwise
    #   false.
    def key? key
      key = key.intern if key.is_a?(String)

      @data.key?(key)
    end # method key?
    alias_method :has_key?, :key?

    # @return [Array<Integer, Symbol>] The keys of the nested errors hashes.
    def keys
      @data.keys.keep_if { |key| key != :__errors }
    end # method keys

    # Returns a new errors object with the combined structure and errors of the
    # current and the given errors objects.
    #
    # @param other [Bronze:Errors] The other errors object to merge.
    #
    # @return [Bronze::Errors] The new errors object.
    def merge other
      dup.update(other)
    end # method merge

    # Returns a flat array of each error from the data structure.
    #
    # @return [Array<Hash>] The errors.
    def to_a
      each.with_object([]) { |error, ary| ary << error }
    end # method to_a

    # Combines the current errors object with the given errors object, adding
    # the structure and errors of the given object to the current object.
    #
    # @param other [Bronze:Errors] The other errors object to merge.
    #
    # @return [Bronze::Errors] The current errors object with the updates.
    def update other
      update_errors_hash(data, other.data)

      self
    end # method update

    protected

    attr_reader :data, :path

    private

    def compare_errors other
      enum = other.each

      each do |error|
        return false unless error == enum.next || other.include?(error)
      end # each

      empty_enumerable?(enum)
    rescue StopIteration
      false
    end # method compare_errors

    def count_errors_in_hash hsh
      count = 0

      hsh.each do |key, value|
        count += key == :__errors ? value.size : count_errors_in_hash(value)
      end # each

      count
    end # method count_errors_in_hash

    def each_error_in_hash hsh, relative_path
      hsh.each do |key, value|
        if key == :__errors
          value.each do |error|
            yield error.merge(:path => relative_path)
          end # each
        else
          each_error_in_hash(value, relative_path + [key]) { |e| yield e }
        end # if-else
      end # each
    end # method each_error_in_hash

    def empty_enumerable? enum
      enum.peek

      false
    rescue StopIteration
      true
    end # method empty_enumerable?

    def hash_has_errors? hsh
      hsh.each do |key, value|
        return true if key == :__errors && !value.empty?

        return true if hash_has_errors?(value)
      end # each

      false
    end # method hash_has_errors?

    def update_errors_hash tgt, src
      src.each do |key, value|
        if key == :__errors
          (tgt[:__errors] ||= []).concat(value)
        else
          update_errors_hash((tgt[key] ||= {}), value)
        end # if-else
      end # each
    end # method update_errors_hash

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end # method tools
  end # class

  # rubocop:enable Metrics/ClassLength
end # module
