# spec/bronze/constraints/identity_constraint_spec.rb

require 'bronze/constraints/constraints_examples'
require 'bronze/constraints/identity_constraint'

RSpec.describe Bronze::Constraints::IdentityConstraint do
  include Spec::Constraints::ConstraintsExamples

  let(:expected) { 'a string' }
  let(:instance) { described_class.new expected }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '::IDENTICAL_TO_ERROR' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:IDENTICAL_TO_ERROR).
        with_value('constraints.errors.identical_to')
    end # it
  end # describe

  describe '::NOT_IDENTICAL_TO_ERROR' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:NOT_IDENTICAL_TO_ERROR).
        with_value('constraints.errors.not_identical_to')
    end # it
  end # describe

  describe '#match' do
    let(:error_type)   { described_class::NOT_IDENTICAL_TO_ERROR }
    let(:error_params) { [expected] }

    it { expect(instance).to respond_to(:match).with(1).argument }

    describe 'with nil' do
      let(:object) { nil }

      include_examples 'should return false and the errors object'
    end # describe

    describe 'with an equal object' do
      let(:object) { 'a string' }

      include_examples 'should return false and the errors object'
    end # describe

    describe 'with the same object' do
      let(:object) { expected }

      include_examples 'should return true and an empty errors object'
    end # describe
  end # describe

  describe '#negated_match' do
    let(:match_method) { :negated_match }
    let(:error_type)   { described_class::IDENTICAL_TO_ERROR }
    let(:error_params) { [expected] }

    it { expect(instance).to respond_to(:negated_match).with(1).argument }

    describe 'with nil' do
      let(:object) { nil }

      include_examples 'should return true and an empty errors object'
    end # describe

    describe 'with an equal object' do
      let(:object) { 'a string' }

      include_examples 'should return true and an empty errors object'
    end # describe

    describe 'with the same object' do
      let(:object) { expected }

      include_examples 'should return false and the errors object'
    end # describe
  end # describe
end # describe
