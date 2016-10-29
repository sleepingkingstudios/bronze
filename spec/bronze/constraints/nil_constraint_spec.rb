# spec/bronze/constraints/nil_constraint_spec.rb

require 'bronze/constraints/constraints_examples'
require 'bronze/constraints/nil_constraint'

RSpec.describe Bronze::Constraints::NilConstraint do
  include Spec::Constraints::ConstraintsExamples

  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '::NIL_ERROR' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:NIL_ERROR).
        with_value('constraints.errors.nil')
    end # it
  end # describe

  describe '::NOT_NIL_ERROR' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:NOT_NIL_ERROR).
        with_value('constraints.errors.not_nil')
    end # it
  end # describe

  describe '#match' do
    let(:error_type)   { described_class::NOT_NIL_ERROR }
    let(:error_params) { [] }

    it { expect(instance).to respond_to(:match).with(1).argument }

    describe 'with nil' do
      let(:object) { nil }

      include_examples 'should return true and an empty errors object'
    end # describe

    describe 'with a non-nil object' do
      let(:object) { Object.new }

      include_examples 'should return false and the errors object'
    end # describe
  end # describe

  describe '#negated_match' do
    let(:match_method) { :negated_match }
    let(:error_type)   { described_class::NIL_ERROR }
    let(:error_params) { [] }

    it { expect(instance).to respond_to(:negated_match).with(1).argument }

    describe 'with nil' do
      let(:object) { nil }

      include_examples 'should return false and the errors object'
    end # describe

    describe 'with a non-nil object' do
      let(:object) { Object.new }

      include_examples 'should return true and an empty errors object'
    end # describe
  end # describe
end # describe
