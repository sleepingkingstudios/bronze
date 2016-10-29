# spec/bronze/constraints/block_constraint_spec.rb

require 'bronze/constraints/constraints_examples'
require 'bronze/constraints/block_constraint'

RSpec.describe Bronze::Constraints::BlockConstraint do
  include Spec::Constraints::ConstraintsExamples

  let(:error)    { nil }
  let(:block)    { ->(int) { int.even? } }
  let(:instance) { described_class.new(error, &block) }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class).
        to be_constructible.
        with(0..1).arguments.
        and_a_block
    end # it
  end # describe

  describe '::NOT_SATISFY_BLOCK_ERROR' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:NOT_SATISFY_BLOCK_ERROR).
        with_value('constraints.errors.not_satisfy_block')
    end # it
  end # describe

  describe '::SATISFY_BLOCK_ERROR' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:SATISFY_BLOCK_ERROR).
        with_value('constraints.errors.satisfy_block')
    end # it
  end # describe

  describe '#match' do
    let(:error_type)   { described_class::NOT_SATISFY_BLOCK_ERROR }
    let(:error_params) { [] }

    it { expect(instance).to respond_to(:match).with(1).argument }

    describe 'with an object that satisfies the block' do
      let(:object) { 0 }

      include_examples 'should return true and an empty errors object'
    end # describe

    describe 'with an object that does not satisfy the block' do
      let(:object) { 1 }

      include_examples 'should return false and the errors object'

      context 'when a custom error class is set' do
        let(:error)      { 'constraints.errors.not_even' }
        let(:error_type) { error }

        include_examples 'should return false and the errors object'
      end # context
    end # describe
  end # describe

  describe '#negated_match' do
    let(:match_method) { :negated_match }
    let(:error_type)   { described_class::SATISFY_BLOCK_ERROR }
    let(:error_params) { [] }

    it { expect(instance).to respond_to(:negated_match).with(1).argument }

    describe 'with an object that satisfies the block' do
      let(:object) { 0 }

      include_examples 'should return false and the errors object'

      context 'when a custom error class is set' do
        let(:error)      { 'constraints.errors.even' }
        let(:error_type) { error }

        include_examples 'should return false and the errors object'
      end # context
    end # describe

    describe 'with an object that does not satisfy the block' do
      let(:object) { 1 }

      include_examples 'should return true and an empty errors object'
    end # describe
  end # describe
end # describe
