# frozen_string_literal: true

require 'rspec/sleeping_king_studios/examples/rspec_matcher_examples'

require 'support/matchers/be_a_result_matcher'

RSpec.describe Spec::Support::Matchers::BeAResultMatcher do
  include RSpec::SleepingKingStudios::Examples::RSpecMatcherExamples

  shared_context 'when the matcher has a failing status expectation' do
    before(:example) { matcher.with_failing_status }
  end

  shared_context 'when the matcher has a passing status expectation' do
    before(:example) { matcher.with_passing_status }
  end

  shared_context 'when the matcher has a value expectation' do
    let(:expected_value) { 'result value' }

    before(:example) { matcher.with_value(expected_value) }
  end

  shared_context 'when the matcher has an errors expectation' do
    let(:expected_errors) do
      [
        'spec.errors.first_error',
        'spec.errors.second_error',
        'spec.errors.third_error'
      ]
    end

    before(:example) { matcher.with_errors(*expected_errors) }
  end

  subject(:matcher) { described_class.new }

  let(:instance) { matcher } # RSpec::SleepingKingStudios compatibility.

  describe '#description' do
    it { expect(matcher).to respond_to(:description).with(0).arguments }

    it { expect(matcher.description).to be == 'be a result' }

    wrap_context 'when the matcher has a failing status expectation' do
      it { expect(matcher.description).to be == 'be a failing result' }
    end

    wrap_context 'when the matcher has a passing status expectation' do
      it { expect(matcher.description).to be == 'be a passing result' }
    end

    wrap_context 'when the matcher has a value expectation' do
      it 'should return the description' do
        expect(matcher.description).to be == 'be a result with specified value'
      end
    end

    wrap_context 'when the matcher has an errors expectation' do
      it 'should return the description' do
        expect(matcher.description).to be == 'be a result with specified errors'
      end
    end

    context 'when the matcher has multiple expectations' do
      include_context 'when the matcher has a failing status expectation'
      include_context 'when the matcher has a value expectation'
      include_context 'when the matcher has an errors expectation'

      it 'should return the description' do
        expect(matcher.description)
          .to be == 'be a failing result with specified value and errors'
      end
    end
  end

  describe '#matches?' do
    shared_examples 'should raise an error when negated' do
      context 'when the matcher is negated' do
        let(:error_message) do
          "`expect().not_to be_a_result().#{method_name}()` is not supported"
        end

        it 'should raise an error' do
          expect { matcher.does_not_match?(actual) }
            .to raise_error RuntimeError, error_message
        end
      end
    end

    let(:failure_message) do
      "expected #{actual.inspect} to be a result"
    end
    let(:failure_message_when_negated) do
      "expected #{actual.inspect} not to be a result"
    end

    describe 'with nil' do
      let(:actual) { nil }

      include_examples 'should fail with a positive expectation'

      include_examples 'should pass with a negative expectation'
    end

    describe 'with an Object' do
      let(:actual) { Object.new }

      include_examples 'should fail with a positive expectation'

      include_examples 'should pass with a negative expectation'
    end

    describe 'with a Cuprum result' do
      let(:actual) { Cuprum::Result.new }

      include_examples 'should pass with a positive expectation'

      include_examples 'should fail with a negative expectation'
    end

    wrap_context 'when the matcher has a passing status expectation' do
      let(:method_name) { :with_passing_status }
      let(:failure_message) do
        "expected #{actual.inspect} to be a passing result"
      end

      describe 'with nil' do
        let(:actual) { nil }
        let(:failure_message) do
          super() + ', but was not a result'
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with an Object' do
        let(:actual) { Object.new }
        let(:failure_message) do
          super() + ', but was not a result'
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with a passing result' do
        let(:actual) { Cuprum::Result.new }

        include_examples 'should pass with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with a failing result' do
        let(:actual) { Cuprum::Result.new.failure! }
        let(:failure_message) do
          super() + ', but the result was failing'
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end
    end

    wrap_context 'when the matcher has a failing status expectation' do
      let(:method_name) { :with_failing_status }
      let(:failure_message) do
        "expected #{actual.inspect} to be a failing result"
      end

      describe 'with nil' do
        let(:actual) { nil }
        let(:failure_message) do
          super() + ', but was not a result'
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with an Object' do
        let(:actual) { Object.new }
        let(:failure_message) do
          super() + ', but was not a result'
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with a failing result' do
        let(:actual) { Cuprum::Result.new.failure! }

        include_examples 'should pass with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with a passing result' do
        let(:actual) { Cuprum::Result.new }
        let(:failure_message) do
          super() + ', but the result was passing'
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end
    end

    wrap_context 'when the matcher has a value expectation' do
      let(:actual_value) { nil }
      let(:method_name)  { :with_value }
      let(:failure_message) do
        "expected #{actual.inspect} to be a result with specified value"
      end
      let(:value_message) do
        "\n" \
        "\n  the result does not match the expected value:" \
        "\n    expected: #{expected_value.inspect}" \
        "\n         got: #{actual_value.inspect}"
      end

      describe 'with nil' do
        let(:actual) { nil }
        let(:failure_message) do
          super() + ', but was not a result'
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with an Object' do
        let(:actual) { Object.new }
        let(:failure_message) do
          super() + ', but was not a result'
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with a passing result' do
        let(:actual) { Cuprum::Result.new }
        let(:failure_message) do
          super() + value_message
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with a failing result' do
        let(:actual) { Cuprum::Result.new.failure! }
        let(:failure_message) do
          super() + value_message
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with a result with non-matching value' do
        let(:actual_value) { 'other value' }
        let(:actual) do
          Cuprum::Result.new.tap { |result| result.value = actual_value }
        end
        let(:failure_message) do
          super() + value_message
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with a result with matching value' do
        let(:actual) do
          Cuprum::Result.new.tap { |result| result.value = expected_value }
        end

        include_examples 'should pass with a positive expectation'

        include_examples 'should raise an error when negated'
      end
    end

    wrap_context 'when the matcher has an errors expectation' do
      let(:actual_errors) { [] }
      let(:method_name) { :with_errors }
      let(:failure_message) do
        "expected #{actual.inspect} to be a result with specified errors"
      end
      let(:errors_message) do
        "\n" \
        "\n  the result does not match the expected errors:" \
        "\n    expected: #{expected_errors.inspect}" \
        "\n         got: #{actual_errors.inspect}"
      end

      describe 'with nil' do
        let(:actual) { nil }
        let(:failure_message) do
          super() + ', but was not a result'
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with an Object' do
        let(:actual) { Object.new }
        let(:failure_message) do
          super() + ', but was not a result'
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with a passing result' do
        let(:actual) { Cuprum::Result.new }
        let(:failure_message) do
          super() + errors_message
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with a failing result' do
        let(:actual) { Cuprum::Result.new.failure! }
        let(:failure_message) do
          super() + errors_message
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with a result with non-matching errors' do
        let(:actual_errors) do
          ['spec.errors.custom_error', 'spec.errors.other_error']
        end
        let(:actual) do
          Cuprum::Result.new.tap { |result| result.errors = actual_errors }
        end
        let(:failure_message) do
          super() + errors_message
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with a result with partially-matching errors' do
        let(:actual_errors) do
          ['spec.errors.custom_error', 'spec.errors.first_error']
        end
        let(:actual) do
          Cuprum::Result.new.tap { |result| result.errors = actual_errors }
        end
        let(:failure_message) do
          super() + errors_message
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with a result with matching errors' do
        let(:actual_errors) { expected_errors }
        let(:actual) do
          Cuprum::Result.new.tap { |result| result.errors = actual_errors }
        end

        include_examples 'should pass with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with a result with unordered errors' do
        let(:actual_errors) { expected_errors.rotate }
        let(:actual) do
          Cuprum::Result.new.tap { |result| result.errors = actual_errors }
        end

        include_examples 'should pass with a positive expectation'

        include_examples 'should raise an error when negated'
      end
    end

    context 'when the matcher has multiple expectations' do
      include_context 'when the matcher has a failing status expectation'
      include_context 'when the matcher has a value expectation'
      include_context 'when the matcher has an errors expectation'

      let(:method_name)   { :with_failing_status }
      let(:actual_value)  { nil }
      let(:actual_errors) { [] }
      let(:failure_message) do
        'be a failing result with specified value and errors'
      end
      let(:value_message) do
        "\n" \
        "\n  the result does not match the expected value:" \
        "\n    expected: #{expected_value.inspect}" \
        "\n         got: #{actual_value.inspect}"
      end
      let(:errors_message) do
        "\n" \
        "\n  the result does not match the expected errors:" \
        "\n    expected: #{expected_errors.inspect}" \
        "\n         got: #{actual_errors.inspect}"
      end

      describe 'with nil' do
        let(:actual) { nil }
        let(:failure_message) do
          super() + ', but was not a result'
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with an Object' do
        let(:actual) { Object.new }
        let(:failure_message) do
          super() + ', but was not a result'
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with a passing result' do
        let(:actual) { Cuprum::Result.new }
        let(:failure_message) do
          super() + ', but the result was passing'
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with a failing result' do
        let(:actual) { Cuprum::Result.new.failure! }
        let(:failure_message) do
          super() + value_message + errors_message
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with a failing result with non-matching errors' do
        let(:actual_errors) do
          ['spec.errors.custom_error', 'spec.errors.other_error']
        end
        let(:actual) do
          Cuprum::Result.new(nil, errors: actual_errors).failure!
        end
        let(:failure_message) do
          super() + value_message + errors_message
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with a failing result with matching errors' do
        let(:actual) do
          Cuprum::Result.new(nil, errors: expected_errors).failure!
        end
        let(:failure_message) do
          super() + value_message
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with a failing result with non-matching value' do
        let(:actual_value) { 'other value' }
        let(:actual)       { Cuprum::Result.new(actual_value).failure! }
        let(:failure_message) do
          super() + value_message + errors_message
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with a failing result with matching value' do
        let(:actual) { Cuprum::Result.new(expected_value).failure! }
        let(:failure_message) do
          super() + errors_message
        end

        include_examples 'should fail with a positive expectation'

        include_examples 'should raise an error when negated'
      end

      describe 'with a failing result with matching value and errors' do
        let(:actual) do
          Cuprum::Result.new(expected_value, errors: expected_errors).failure!
        end

        include_examples 'should pass with a positive expectation'

        include_examples 'should raise an error when negated'
      end
    end
  end

  describe '#with_errors' do
    let(:errors) { ['spec.errors.custom_error'] }

    it 'should define the method' do
      expect(matcher)
        .to respond_to(:with_errors)
        .and_unlimited_arguments
    end

    it { expect(matcher).to alias_method(:with_errors).as(:and_errors) }

    it { expect(matcher.with_errors(*errors)).to be matcher }
  end

  describe '#with_failing_status' do
    it { expect(matcher).to respond_to(:with_failing_status).with(0).arguments }

    it { expect(matcher.with_failing_status).to be matcher }
  end

  describe '#with_passing_status' do
    it { expect(matcher).to respond_to(:with_passing_status).with(0).arguments }

    it { expect(matcher.with_passing_status).to be matcher }
  end

  describe '#with_value' do
    it { expect(matcher).to respond_to(:with_value).with(1).argument }

    it { expect(matcher.with_value(Object.new)).to be matcher }
  end
end
