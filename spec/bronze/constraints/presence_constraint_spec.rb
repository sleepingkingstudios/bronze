# spec/bronze/constraints/presence_constraint_spec.rb

require 'bronze/constraints/constraint_examples'
require 'bronze/constraints/presence_constraint'

RSpec.describe Bronze::Constraints::PresenceConstraint do
  include Spec::Constraints::ConstraintExamples

  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '::EMPTY_ERROR' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:EMPTY_ERROR).
        with_value('constraints.errors.messages.empty')
    end # it
  end # describe

  describe '::NOT_EMPTY_ERROR' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:NOT_EMPTY_ERROR).
        with_value('constraints.errors.messages.not_empty')
    end # it
  end # describe

  describe '#match' do
    let(:error_type)   { described_class::EMPTY_ERROR }
    let(:error_params) { {} }

    it { expect(instance).to respond_to(:match).with(1).argument }

    describe 'with nil' do
      let(:object) { nil }

      include_examples 'should return false and the errors object'
    end # describe

    describe 'with a non-nil object' do
      let(:object) { Object.new }

      include_examples 'should return true and an empty errors object'
    end # describe

    describe 'with an empty array' do
      let(:object) { [] }

      include_examples 'should return false and the errors object'
    end # describe

    describe 'with a non-empty string' do
      let(:object) { %w(an array) }

      include_examples 'should return true and an empty errors object'
    end # describe

    describe 'with an empty hash' do
      let(:object) { {} }

      include_examples 'should return false and the errors object'
    end # describe

    describe 'with a non-empty hash' do
      let(:object) { { :a => :hash } }

      include_examples 'should return true and an empty errors object'
    end # describe

    describe 'with an empty string' do
      let(:object) { '' }

      include_examples 'should return false and the errors object'
    end # describe

    describe 'with a non-empty string' do
      let(:object) { 'a string' }

      include_examples 'should return true and an empty errors object'
    end # describe
  end # describe

  describe '#negated_match' do
    let(:match_method) { :negated_match }
    let(:error_type)   { described_class::NOT_EMPTY_ERROR }
    let(:error_params) { {} }

    it { expect(instance).to respond_to(:negated_match).with(1).argument }

    describe 'with nil' do
      let(:object) { nil }

      include_examples 'should return true and an empty errors object'
    end # describe

    describe 'with a non-nil object' do
      let(:object) { Object.new }

      include_examples 'should return false and the errors object'
    end # describe

    describe 'with an empty array' do
      let(:object) { [] }

      include_examples 'should return true and an empty errors object'
    end # describe

    describe 'with a non-empty string' do
      let(:object) { %w(an array) }

      include_examples 'should return false and the errors object'
    end # describe

    describe 'with an empty hash' do
      let(:object) { {} }

      include_examples 'should return true and an empty errors object'
    end # describe

    describe 'with a non-empty hash' do
      let(:object) { { :a => :hash } }

      include_examples 'should return false and the errors object'
    end # describe

    describe 'with an empty string' do
      let(:object) { '' }

      include_examples 'should return true and an empty errors object'
    end # describe

    describe 'with a non-empty string' do
      let(:object) { 'a string' }

      include_examples 'should return false and the errors object'
    end # describe
  end # describe
end # describe
