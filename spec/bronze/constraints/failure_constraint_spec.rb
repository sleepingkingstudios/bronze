# spec/bronze/constraints/failure_constraint_spec.rb

require 'bronze/constraints/constraint_examples'
require 'bronze/constraints/failure_constraint'

RSpec.describe Spec::Constraints::FailureConstraint do
  include Spec::Constraints::ConstraintExamples

  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with_unlimited_arguments }
  end # describe

  describe '::INVALID_ERROR' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:INVALID_ERROR).
        with_value('constraints.errors.messages.invalid_object')
    end # it
  end # describe

  describe '#match' do
    let(:error_type) { described_class::INVALID_ERROR }
    let(:object)     { double('object') }

    it { expect(instance).to respond_to(:match).with(1).argument }

    include_examples 'should return false and the errors object'

    context 'with an error type' do
      let(:error_type) { :unable_to_log_out_because_you_are_not_logged_in }
      let(:instance)   { described_class.new error_type }

      include_examples 'should return false and the errors object'
    end # context

    context 'with an error type and error params' do
      let(:error_type)   { :supply_limit_exceeded }
      let(:error_params) { { :spawn => 'more_overlords' } }
      let(:instance)     { described_class.new error_type, **error_params }

      include_examples 'should return false and the errors object'
    end # context
  end # describe

  describe '#negated_match' do
    let(:match_method) { :negated_match }
    let(:error_type)   { described_class::VALID_ERROR }
    let(:object)       { double('object') }

    it { expect(instance).to respond_to(:negated_match).with(1).argument }

    include_examples 'should return true and an empty errors object'
  end # describe
end # describe
