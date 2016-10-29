# lib/bronze/errors/errors.rb

require 'bronze/errors/error'
require 'sleeping_king_studios/tools/toolbox/delegator'

module Bronze::Errors
  # Class for encapsulating errors encountered during an operation or process.
  class Errors
    extend SleepingKingStudios::Tools::Toolbox::Delegator

    # @param nesting [Array] The nesting of the current errors object.
    def initialize nesting = []
      @nesting = nesting
      @errors  = []

      @children = Hash.new do |hsh, key|
        errors = self.class.new(nesting + [key])
        errors.parent = self

        hsh[key] = errors
      end # new
    end # constructor

    # @return [Array] The nesting of the current errors object.
    attr_reader :nesting

    # @!method each
    #   Iterates through the errors and yields each error to the given block.
    #
    #   @yieldparam error [Bronze::Errors::Error] The current error object.

    # @!method map
    #   Iterates through the errors and yields each error to the given block,
    #   returning an array containing the results of each yield.
    #
    #   @yieldparam error [Bronze::Errors::Error] The current error object.
    delegate :each, :include?, :map, :to => :to_a

    # @return [Boolean] True if the other object is an Errors object of the same
    #   class and has the same errors.
    def == other
      return false unless other.class == self.class

      errors == other.errors && children == other.children
    end # method ==

    # Finds or creates a child errors object with the given name, representing
    # an attribute or nested relation.
    #
    # @param child_name [String, Symbol] The name of the child errors object.
    def [] child_name
      children[child_name]
    end # method []

    # Appends an error to the objcet.
    #
    # @param error_type [String, Symbol] The error type.
    # @param error_params [Array] Array of optional error parameters.
    def add error_type, *error_params
      @errors << Error.new(nesting, error_type, error_params)

      self
    end # method add

    # Counts the number of errors.
    #
    # @return [Integer] The number of errors.
    def count
      children.reduce(@errors.count) do |memo, (_, child)|
        memo + child.count
      end # reduce
    end # method count

    # Iterates through the errors and returns true if the errors object
    # includes the given error.
    #
    # @param error [Bronze::Errors::Error] The error to check.
    #
    # @return [Boolean] True if the errors object includes the given error,
    #   otherwise false.
    def detect &block
      return true if @errors.detect(&block)

      children.any? { |_, child| child.detect(&block) }
    end # method detect

    # @return [Boolean] True if there are no errors on the object or on any
    #   child errors object; otherwise false.
    def empty?
      return false unless @errors.empty?

      children.each do |_, child|
        return false unless child.empty?
      end # each

      true
    end # method empty?

    # Iterates through the errors and returns true if the errors object
    # includes the given error.
    #
    # @param error [Bronze::Errors::Error] The error to check.
    #
    # @return [Boolean] True if the errors object includes the given error,
    #   otherwise false.
    def include? error
      return true if @errors.include? error

      children.any? { |_, child| child.include?(error) }
    end # method include?

    # Returns the listed errors and all errors from child errors objects.
    #
    # @return [Array] The errors.
    def to_a
      ary = @errors.dup

      children.each do |_, child|
        ary.concat(child.to_a)
      end # each

      ary
    end # method to_a

    # Adds the errors from the other errors object to the current errors object.
    #
    # @param other [Errors] The other errors object.
    def update other
      other.each do |error|
        child = resolve_nesting(self, *error.nesting)

        child.errors << error.with_nesting(child.nesting)
      end # each
    end # method update

    protected

    attr_accessor :parent

    attr_reader :children

    attr_reader :errors

    private

    def resolve_nesting parent, *fragments
      fragments.reduce(parent) { |memo, fragment| memo[fragment] }
    end # method resolve_nesting
  end # class
end # module
