# spec/bronze/contracts/success_constraint_spec.rb

require 'bronze/contracts/constraints_examples'
require 'bronze/contracts/success_constraint'

RSpec.describe Spec::SuccessConstraint do
  include Spec::Contracts::ConstraintsExamples

  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '#match' do
    let(:object) { double('object') }

    it { expect(instance).to respond_to(:match).with(1).argument }

    include_examples 'should return true and an empty errors object'
  end # describe
end # describe
