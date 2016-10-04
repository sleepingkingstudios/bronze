# spec/bronze/contracts/failure_constraint_spec.rb

require 'bronze/contracts/failure_constraint'

RSpec.describe Spec::FailureConstraint do
  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '#match' do
    let(:object) { double('object') }

    it { expect(instance).to respond_to(:match).with(1).argument }

    it 'should return false and the errors object' do
      result, errors = instance.match object

      expect(result).to be false
      expect(errors).to include { |error|
        error.type == described_class::INVALID_ERROR
      } # errors
    end # it
  end # describe
end # describe
