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
    delegate :each, :map, :to => :to_a

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
    end # method <<

    # @return [Boolean] True if there are no errors on the object or on any
    #   child errors object; otherwise false.
    def empty?
      return false unless @errors.empty?

      children.each do |_, child|
        return false unless child.empty?
      end # each

      true
    end # method empty?

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

    protected

    attr_accessor :parent

    attr_reader :children
  end # class
end # module
