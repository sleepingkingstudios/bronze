# spec/bronze/constraints/failure_constraint_spec.rb

require 'bronze/constraints/constraints_examples'
require 'bronze/constraints/failure_constraint'

RSpec.describe Spec::FailureConstraint do
  include Spec::Constraints::ConstraintsExamples

  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with_unlimited_arguments }
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
      let(:error_params) { [:spawn_more_overlords, 100, :minerals] }
      let(:instance)     { described_class.new error_type, *error_params }

      include_examples 'should return false and the errors object'
    end # context
  end # describe
end # describe
