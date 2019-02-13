# frozen_string_literal: true

require 'bronze'

module Bronze
  # Utility object that wraps a hash-of-hashes nested errors data structure.
  class Errors # rubocop:disable Metrics/ClassLength
    include Enumerable

    ERRORS_KEY = :ERROR_DATA
    private_constant :ERRORS_KEY

    def initialize(data: {}, path: [])
      @path = path || []
      @data = data || {}

      @data[ERRORS_KEY] ||= []
    end

    # Compares the given object to the errors. Returns false if the other object
    # is not an errors object or does not have the same errors.
    #
    # @param other [Bronze::Errors] The object to compare.
    #
    # @return [Boolean]
    def ==(other)
      return false unless other.is_a?(Enumerable)

      compare_errors(other)
    end

    # Returns a reference to the inner errors data structure at the given key.
    #
    # @param key [Integer, Symbol] The inner data key.
    #
    # @return [Bronze::Errors] The errors proxy for the referenced data.
    def [](key)
      key = key.intern if key.is_a?(String)
      hsh = @data[key] ||= {}

      Bronze::Errors.new(data: hsh, path: [*@path, key])
    end

    # Copies the hash and sets it as the inner errors data structure at the
    # given key.
    #
    # @param key [Integer, Symbol] The inner data key.
    # @param value [Hash, Bronze::Errors] The hash or errors proxy to copy.
    def []=(key, value)
      key  = key.intern if key.is_a?(String)
      data = value.is_a?(Bronze::Errors) ? value.data : value

      @data[key] = tools.hash.deep_dup(data)
    end

    # Adds an error with the specified type and params.
    #
    # @param type [String] The error type.
    # @param params [Hash] Additional params for the error, if any.
    def add(type, params = {})
      type = type.to_s if type.is_a?(Symbol)

      @data[ERRORS_KEY] << { type: type, params: params }

      self
    end

    # Removes all errors from the proxy object.
    #
    # @return [Bronze::Errors] The (empty) errors proxy.
    def clear
      @data = { ERRORS_KEY => [] }

      self
    end

    # @return [Integer] The number of errors in the data structure.
    def count
      count_errors_in_hash @data
    end
    alias_method :length, :count
    alias_method :size,   :count

    # Removes the inner data at the given key and returns it wrapped with a
    # proxy object.
    #
    # @param key [Integer, Symbol] The inner data key.
    #
    # @return [Bronze::Errors] The errors proxy for the referenced data.
    def delete(key)
      Bronze::Errors.new(data: @data.delete(key))
    end

    # Returns a reference to the nested inner errors data structure referenced
    # by the given keys.
    #
    # @param keys [Array<Integer, Symbol>] The inner data keys.
    #
    # @return [Bronze::Errors] The errors proxy for the referenced data.
    def dig(*keys)
      keys.reduce(self) { |proxy, key| proxy[key] }
    end

    # @return [Bronze::Errors] A deep copy of the errors object.
    def dup
      self.class.new(data: tools.hash.deep_dup(data), path: path)
    end

    # Iterates through the errors in errors object and all child errors objects,
    # yielding each to the given block.
    #
    # @yieldparam error [Hash] The current error.
    def each
      return enum_for(:each) unless block_given?

      each_error_in_hash(@data, @path) { |error| yield error }
    end

    # @return True if the data structure has no errors, otherwise false.
    def empty?
      !hash_has_errors?(@data)
    end

    # Returns true if the data structure includes a matching error, otherwise
    # false. Each error in the data structure is compared to the expectation
    # using a hash subset comparison. If the expected object is not a hash, it
    # is converted to the form { :type => expected }.
    #
    # @param expected [Hash, Object] The expected error or error type.
    #
    # @return [Boolean] True if an error in the data structure matches the
    #   expectation, otherwise false.
    def include?(expected)
      unless expected.is_a?(Hash)
        return any? { |error| error[:type] == expected }
      end

      includes_hash?(expected)
    end

    # @param key [Integer, Symbol] The inner data key.
    #
    # @return [Boolean] True if the data structure has the given key, otherwise
    #   false.
    def key?(key)
      key = key.intern if key.is_a?(String)

      @data.key?(key)
    end
    alias_method :has_key?, :key?

    # @return [Array<Integer, Symbol>] The keys of the nested errors hashes.
    def keys
      @data.each_key.reject { |key| key == ERRORS_KEY }
    end

    # Returns a new errors object with the combined structure and errors of the
    # current and the given errors objects.
    #
    # @param other [Bronze:Errors] The other errors object to merge.
    #
    # @return [Bronze::Errors] The new errors object.
    def merge(other)
      dup.update(other)
    end

    # Combines the current errors object with the given errors object, adding
    # the structure and errors of the given object to the current object.
    #
    # @param other [Bronze:Errors] The other errors object to merge.
    #
    # @return [Bronze::Errors] The current errors object with the updates.
    def update(other)
      update_errors_hash(data, other.data)

      self
    end

    protected

    attr_reader :data

    attr_reader :path

    private

    def compare_errors(other)
      enum = other.each

      each do |error|
        return false unless error == enum.next || other.include?(error)
      end

      empty_enumerable?(enum)
    rescue StopIteration
      false
    end

    def count_errors_in_hash(hsh)
      hsh.reduce(0) do |count, (key, value)|
        count + (key == ERRORS_KEY ? value.size : count_errors_in_hash(value))
      end
    end

    def each_error_in_hash(hsh, relative_path)
      hsh.each do |key, value|
        if key == ERRORS_KEY
          value.each { |error| yield error.merge(path: relative_path) }
        else
          each_error_in_hash(value, relative_path + [key]) { |e| yield e }
        end
      end
    end

    def empty_enumerable?(enum)
      enum.peek

      false
    rescue StopIteration
      true
    end

    def hash_has_errors?(hsh)
      hsh.each do |key, value|
        return true if key == ERRORS_KEY && !value.empty?

        return true if hash_has_errors?(value)
      end

      false
    end

    def includes_hash?(hsh)
      any? do |error|
        next false if hsh.key?(:path) && error[:path] != hsh[:path]

        error[:type] == hsh[:type] && error[:params] == hsh[:params]
      end
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    def update_errors_hash(tgt, src)
      src.each do |key, value|
        if key == ERRORS_KEY
          (tgt[ERRORS_KEY] ||= []).concat(value)
        else
          update_errors_hash((tgt[key] ||= {}), value)
        end
      end
    end
  end
end
