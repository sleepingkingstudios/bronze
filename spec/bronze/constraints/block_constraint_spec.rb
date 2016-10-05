# spec/bronze/constraints/block_constraint_spec.rb

require 'bronze/constraints/constraints_examples'
require 'bronze/constraints/block_constraint'

RSpec.describe Bronze::Constraints::BlockConstraint do
  include Spec::Constraints::ConstraintsExamples

  let(:block)    { ->(int) { int.even? } }
  let(:instance) { described_class.new(&block) }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class).to be_constructible.with(0).arguments.and_a_block
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
    end # describe
  end # describe
end # describe
