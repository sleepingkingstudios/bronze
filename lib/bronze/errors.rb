# lib/bronze/errors/errors_proxy.rb

require 'sleeping_king_studios/tools/toolbelt'

require 'bronze/errors'

module Bronze
  # Utility object that wraps a hash-of-hashes nested errors data structure.
  class Errors
    include Enumerable

    def initialize data: {}, path: []
      @path = path || []
      @data = data || {}

      @data[:__errors] ||= []
    end # method errors

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
      hsh = { :type => type, :params => params }

      @data[:__errors] << hsh

      hsh
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

    # Returns a flat array of each error from the data structure.
    #
    # @return [Array<Hash>] The errors.
    def to_a
      each.with_object([]) { |error, ary| ary << error }
    end # method to_a

    protected

    attr_reader :data, :path

    private

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

    def hash_has_errors? hsh
      hsh.each do |key, value|
        return true if key == :__errors && !value.empty?

        return true if hash_has_errors?(value)
      end # each

      false
    end # method hash_has_errors?

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end # method tools
  end # class
end # module
