# spec/bronze/constraints/success_constraint_spec.rb

require 'bronze/constraints/constraint_examples'
require 'bronze/constraints/success_constraint'

RSpec.describe Spec::Constraints::SuccessConstraint do
  include Spec::Constraints::ConstraintExamples

  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '::VALID_ERROR' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:VALID_ERROR).
        with_value('constraints.errors.valid_object')
    end # it
  end # describe

  describe '#match' do
    let(:object) { double('object') }

    it { expect(instance).to respond_to(:match).with(1).argument }

    include_examples 'should return true and an empty errors object'
  end # describe

  describe '#negated_match' do
    let(:match_method) { :negated_match }
    let(:error_type)   { described_class::VALID_ERROR }
    let(:object)       { double('object') }

    it { expect(instance).to respond_to(:negated_match).with(1).argument }

    include_examples 'should return false and the errors object'
  end # describe
end # describe
