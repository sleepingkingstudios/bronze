# spec/bronze/constraints/equality_constraint_spec.rb

require 'bronze/constraints/constraints_examples'
require 'bronze/constraints/equality_constraint'

RSpec.describe Bronze::Constraints::EqualityConstraint do
  include Spec::Constraints::ConstraintsExamples

  let(:expected) { 'a string' }
  let(:instance) { described_class.new expected }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#match' do
    let(:error_type)   { described_class::NOT_EQUAL_TO_ERROR }
    let(:error_params) { [expected] }

    it { expect(instance).to respond_to(:match).with(1).argument }

    describe 'with nil' do
      let(:object) { nil }

      include_examples 'should return false and the errors object'
    end # describe

    describe 'with an equal object' do
      let(:object) { 'a string' }

      include_examples 'should return true and an empty errors object'
    end # describe

    describe 'with the same object' do
      let(:object) { expected }

      include_examples 'should return true and an empty errors object'
    end # describe
  end # describe
end # describe
