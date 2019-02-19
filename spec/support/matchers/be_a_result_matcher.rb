# frozen_string_literal: true

require 'cuprum/result'

require 'rspec/sleeping_king_studios/matchers/base_matcher'

require 'support/matchers'

module Spec::Support::Matchers
  # rubocop:disable Metrics/ClassLength

  # A matcher for expecting a value to be a Cuprum::Result
  class BeAResultMatcher < RSpec::SleepingKingStudios::Matchers::BaseMatcher
    DEFAULT_VALUE = Object.new.freeze
    private_constant :DEFAULT_VALUE

    def initialize
      super

      @expected_errors = []
      @expected_status = nil
      @expected_value  = DEFAULT_VALUE
    end

    # @return [String] a description of the expected conditions.
    def description
      desc = "be a #{status_message}result"

      if expected_errors? && expected_value?
        desc += ' with specified value and errors'
      elsif expected_errors?
        desc += ' with specified errors'
      elsif expected_value?
        desc += ' with specified value'
      end

      desc
    end

    # Tests the actual object to see if it is a Cuprum::Result. If the matcher
    # has any additional expectations, such as a status, value or errors
    # expectation, an error is raised.
    #
    # @param [Object] actual The object to test against the matcher.
    #
    # @return [Boolean] false if the object matches, otherwise true.
    #
    # @raise RuntimeError if the matcher has any additional expectations.
    def does_not_match?(actual)
      super

      if expected_status?
        raise unsupported_negation!("with_#{status_message.strip}_status")
      end

      raise unsupported_negation!('with_errors') if expected_errors?

      raise unsupported_negation!('with_value') if expected_value?

      !actual_is_result?
    end

    # Message for when the object does not match, but was expected to.
    #
    # @return [String] the failure message.
    def failure_message
      message = "expected #{actual.inspect} to #{description}"

      return message unless additional_expectations?

      return message + ', but was not a result' unless actual_is_result?

      unless status_matches?
        return message + ", but the result was #{actual_status}"
      end

      message += value_message unless value_matches?

      message += errors_message unless errors_match?

      message
    end

    # Tests the actual object to see if it is a Cuprum::Result, and matches the
    # additional conditions, if any.
    #
    # @param [Object] actual The object to test against the matcher.
    #
    # @return [Boolean] true if the object matches, otherwise false.
    def matches?(actual)
      super

      actual_is_result? && status_matches? && value_matches? && errors_match?
    end

    # Sets an expectation that the result has the given errors.
    #
    # @param [Array] errors The expected errors.
    #
    # @return [BeAResultMatcher] the matcher.
    def with_errors(*errors)
      @expected_errors = errors

      self
    end
    alias_method :and_errors, :with_errors

    # Sets an expectation that the result is failing.
    #
    # @return [BeAResultMatcher] the matcher.
    def with_failing_status
      @expected_status = :failure

      self
    end

    # Sets an expectation that the result is passing.
    #
    # @return [BeAResultMatcher] the matcher.
    def with_passing_status
      @expected_status = :success

      self
    end

    # Sets an expectation that the result has the given value.
    #
    # @param [Object] value The expected value.
    #
    # @return [BeAResultMatcher] the matcher.
    def with_value(value)
      @expected_value = value

      self
    end

    private

    def actual_is_result?
      @actual_is_result ||= actual.is_a?(Cuprum::Result)
    end

    def actual_status
      actual.success? ? 'passing' : 'failing'
    end

    def additional_expectations?
      expected_status? || expected_errors? || expected_value?
    end

    def errors_match?
      # TODO: Support @expected_errors as RSpec matcher, e.g.
      #   be_a_result.with_errors(contain_exactly(*expected_errors))

      return @errors_match unless @errors_match.nil?

      return @errors_match = true unless expected_errors?

      @errors_match = @expected_errors.all? do |expected_error|
        actual.errors.include?(expected_error)
      end
    end

    def errors_message
      "\n" \
      "\n  the result does not match the expected errors:" \
      "\n    expected: #{@expected_errors.inspect}" \
      "\n         got: #{actual.errors.to_a.inspect}"
    end

    def expected_errors?
      !@expected_errors.empty?
    end

    def expected_status?
      !@expected_status.nil?
    end

    def expected_value?
      @expected_value != DEFAULT_VALUE
    end

    def status_matches?
      return @status_matches unless @status_matches.nil?

      @status_matches =
        case @expected_status
        when :success
          actual.success?
        when :failure
          actual.failure?
        else
          true
        end
    end

    def status_message
      case @expected_status
      when :success
        'passing '
      when :failure
        'failing '
      else
        ''
      end
    end

    def unsupported_negation!(method_name)
      raise RuntimeError,
        "`expect().not_to be_a_result().#{method_name}()` is not supported",
        caller[1..-1]
    end

    def value_matches?
      # TODO: Support @expected_value as RSpec matcher, e.g.
      #   be_a_result.with_value(an_instance_of String)

      return @value_matches unless @value_matches.nil?

      return @value_matches = true unless expected_value?

      @value_matches = @expected_value == actual.value
    end

    def value_message
      "\n" \
      "\n  the result does not match the expected value:" \
      "\n    expected: #{@expected_value.inspect}" \
      "\n         got: #{actual.value.inspect}"
    end
  end
  # rubocop:enable Metrics/ClassLength
end
