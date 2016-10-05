# spec/bronze/contracts/failure_constraint_spec.rb

require 'bronze/contracts/constraints_examples'
require 'bronze/contracts/failure_constraint'

RSpec.describe Spec::FailureConstraint do
  include Spec::Contracts::ConstraintsExamples

  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '#match' do
    let(:error_type) { described_class::INVALID_ERROR }
    let(:object)     { double('object') }

    it { expect(instance).to respond_to(:match).with(1).argument }

    include_examples 'should return false and the errors object'
  end # describe
end # describe
